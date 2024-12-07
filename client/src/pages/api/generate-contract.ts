import type { NextApiRequest, NextApiResponse } from 'next';
import { CairoContractGenerator } from '../../lib/contract-generator1';
import { Readable } from 'stream';

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


        const stream = new Readable({
            read() { } // Required for a readable stream
        });

        // Pipe the stream to the response
        res.setHeader('Content-Type', 'text/plain');
        stream.pipe(res);

        stream.push('Starting contract generation...\n');

        const result = await generator.generateContract(bodyofthecall);

        if (!result.success) {
            stream.push(`Error: ${result.error}\n`);
            stream.push(null); // End the stream
            return;
        }

        stream.push('Contract generated successfully.\n');
        stream.push(`Source Code:\n${result.sourceCode}\n`);

        const filePath = await generator.saveContract(result.sourceCode!, 'lib');
        stream.push(`Contract saved at: ${filePath}\n`);
        stream.push(null); // End the stream
    } catch (error) {
        console.error('API error:', error);
        return res.status(500).json({
            error: error instanceof Error ? error.message : 'An unexpected error occurred'
        });
    }
}