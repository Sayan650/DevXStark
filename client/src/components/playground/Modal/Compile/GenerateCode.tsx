import React, { useState } from 'react'
import { Button } from '../../../ui/button';
import axios from 'axios';

export default function GenerateCode({ nodes, edges, flowSummary, setDisplayState, setLoading, setSourceCode }) {
    const [selectedOption, setSelectedOption] = useState("");
    const [responseContent, setResponseContent] = useState('');
    return (
        <>
            <div className='w-17'>
                <h2 className="text-2xl mt-4 mb-4 text-black font-semibold">Confirm Flow Summary?</h2>
                <div className="bg-[#d5bdaf] rounded-lg shadow-md p-4 border-2 border-[#2A2A2A]">
                    {flowSummary.map((item, index) => (
                        <div key={index} className="mb-2 flex items-center">
                            <span className="mr-2 text-red-600">{index + 1}.</span>
                            <span className="text-black">{item.content}</span>
                        </div>
                    ))}
                </div>

                <div className="mt-4 flex flex-col gap-1">
                    <div className=" text-lg text-black font-semibold">
                        Select Blockchain:
                    </div>
                    <select
                        id="blockchain-select"
                        value={selectedOption}
                        onChange={(e) => setSelectedOption(e.target.value)}
                        className="p-2 bg-[#d5bdaf] text-black rounded border border-gray-600"
                        defaultValue=""
                    >
                        <option value="" disabled />
                        <option value="blockchain1">Starknet</option>
                        <option value="blockchain2">Base</option>
                        <option value="blockchain3">Polygon</option>
                        <option value="blockchain3">Supra MoveVM</option>
                    </select>
                </div>
                {!!selectedOption.length && <div className='mt-5'><Button size='lg' onClick={generateCodeHandler}>Generate</Button></div>}
            </div>
        </>
    )
    async function generateCodeHandler() {
        try {

            // setDisplayState("contract")
            const response = await fetch('/api/generate-contract', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ nodes, edges, flowSummary }),
            });

            if (!response.body) {
                console.error('ReadableStream not supported in this browser.');
                return;
            }

            const reader = response.body.getReader();
            const decoder = new TextDecoder('utf-8');
            let result = '';

            while (true) {
                const { done, value } = await reader.read();
                if (done) break;
                const chunk = decoder.decode(value, { stream: true });
                result += chunk;
                console.log(chunk); // Log each chunk of data
                setResponseContent((prev) => prev + chunk);
            }
        } catch (error) {
            console.log(error.message);
        }

    }
}
