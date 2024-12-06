const { Anthropic } = require('@anthropic-ai/sdk');
const { getStarknetSystemPrompt } = require('../config/prompts');

class StarknetContractAuditor {
    constructor(apiKey) {
        this.claude = new Anthropic({ apiKey: apiKey });
    }

    async auditContract(contractCode) {
        try {
            const completion = await this.claude.messages.create({
                model: "claude-3-opus-20240229",
                system: getStarknetSystemPrompt(),
                max_tokens: 4096,
                messages: [
                    { 
                        role: "user", 
                        content: `Carefully audit the following Starknet smart contract and provide a STRICTLY FORMATTED JSON response:\n\n${contractCode}`
                    }
                ]
            });

            // Extract the response text
            const responseText = completion.content[0].text;

            // Multiple strategies to extract JSON
            const extractJSON = (text) => {
                // Try code block extraction
                const codeBlockMatch = text.match(/```json\n([\s\S]*?)```/);
                if (codeBlockMatch) return codeBlockMatch[1].trim();

                // Try between first { and last }
                const bracketMatch = text.match(/\{[\s\S]*\}/);
                if (bracketMatch) return bracketMatch[0].trim();

                // Last resort: try to clean and parse
                const cleanedText = text
                    .replace(/^[^{]*/, '')  // Remove everything before first {
                    .replace(/[^}]*$/, ''); // Remove everything after last }
                return cleanedText;
            };

            const jsonContent = extractJSON(responseText);

            // Validate and parse JSON
            let parsedResult;
            try {
                parsedResult = JSON.parse(jsonContent);
            } catch (parseError) {
                console.error("Raw response text:", responseText);
                throw new Error(`JSON Parsing Failed: ${parseError.message}`);
            }

            // Validate required fields
            const requiredFields = [
                'contract_name', 
                'security_score', 
                'original_contract_code', 
                'corrected_contract_code', 
                'vulnerabilities'
            ];

            requiredFields.forEach(field => {
                if (!parsedResult[field]) {
                    throw new Error(`Missing required field: ${field}`);
                }
            });

            return parsedResult;
        } catch (error) {
            console.error("Audit parsing comprehensive error:", error);
            console.error("Full response text:", completion.content[0].text);
            throw error;
        }
    }
}

module.exports = StarknetContractAuditor;