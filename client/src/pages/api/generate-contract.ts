import type { NextApiRequest, NextApiResponse } from 'next';
import { CairoContractGenerator } from '../../lib/contract-generator';

type ResponseData = {
    success?: boolean;
    sourceCode?: string;
    filePath?: string;
    error?: string;
};

// Export a default function that handles the API route
export default async function handler(
    req: NextApiRequest,
    res: NextApiResponse<ResponseData>
) {
    // Only allow POST requests
    if (req.method !== 'POST') {
        return res.status(405).json({ error: 'Method not allowed' });
    }

    try {
        const { nodes, edges, flowSummary } = req.body;

        console.log({ nodes, edges, flowSummary });

        const flowSummaryJSON = {
            nodes: nodes,
            edges: edges,
            summary: flowSummary
        };

        const bodyofthecall = JSON.stringify(flowSummaryJSON)
            .replace(/[{}"]/g, '')
            .replace(/:/g, ': ')
            .replace(/,/g, ', ');
        // Create an instance of our contract generator
        const generator = new CairoContractGenerator();
        // console.log('bodyofthecall', bodyofthecall);


        // Generate the contract
        const result = await generator.generateContract(bodyofthecall);

        if (!result.success) {
            return res.status(500).json({
                error: result.error
            });
        }

        // Save the generated contract
        const filePath = await generator.saveContract(
            result.sourceCode!,
            'lib'
        );

        // Return success response
        return res.status(200).json({
            success: true,
            sourceCode: result.sourceCode,
            filePath
        });
    } catch (error) {
        console.error('API error:', error);
        return res.status(500).json({
            error: error instanceof Error ? error.message : 'An unexpected error occurred'
        });
    }
}