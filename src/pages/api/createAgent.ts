import type { NextApiRequest, NextApiResponse } from "next";
import { z } from 'zod';

const DataSchema = z.object({
  how: z.string(),
  work: z.string(),
  personality: z.string(),
  dev: z.string(),
  twitterAccess: z.boolean(),
  typeOfTweets: z.string(),
});

export default async function handler(
  req: NextApiRequest,
  res: NextApiResponse,
) {
  if (req.method === 'POST') {
    await POST(req, res);
  }

}

async function POST(req: NextApiRequest,
  res: NextApiResponse,) {
  try {
    //receiving data from frontend
    const data = DataSchema.parse(req.body);
    console.log(data);

    // sending data to the smart contract

    //nft created is unsuccessful then we tell the frontend that the nft creation was unsuccessful

    // nft created successfully

    // we get transaction addresss

    // sent to langchain agent
  } catch (error) {
    res.status(400).json({ error: (error as Error).message });
  }
}
