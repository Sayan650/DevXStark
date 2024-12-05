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
                        content: `Carefully audit the following Starknet smart contract and provide a COMPLETE, VALID JSON response:\n\n${contractCode}`
                    }
                ]
            });

            // Extract the response text
            const responseText = completion.content[0].text;

            // Extract JSON from code block or plain text
            const jsonMatch = responseText.match(/```json\n([\s\S]*?)```/);
            const jsonContent = jsonMatch 
                ? jsonMatch[1].trim() 
                : responseText.trim();

            // Parse and validate JSON
            const parsedResult = JSON.parse(jsonContent);

            // Validate required fields
            if (!parsedResult.contract_name || !parsedResult.security_score) {
                throw new Error('Invalid audit result structure');
            }

            return parsedResult;
        } catch (error) {
            console.error("Audit parsing failed:", error);
            console.error("Raw response:", completion.content[0].text);
            throw new Error(`Contract audit parsing failed: ${error.message}`);
        }
    }
}

module.exports = StarknetContractAuditor;