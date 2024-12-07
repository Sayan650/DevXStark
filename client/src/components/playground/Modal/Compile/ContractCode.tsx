import React, { useState } from 'react'
import { Button } from '../../../ui/button'
export default function ContractCode({ nodes, edges, flowSummary, sourceCode, setSourceCode, setDisplayState, }) {
    const [editable, setEditable] = useState(false);

    return (
        <>
            <div className='text-black text-2xl font-bold'>Contract Code</div>
            <div
                className={`text-black mt-1 custom-scrollbar pl-2 border-4 border-black rounded-xl ${editable ? 'bg-yellow-200' : 'bg-yellow-100'}`}>
                <pre>
                    <code
                        contentEditable={editable}
                        spellCheck="false"
                        style={{
                            outline: 'none',
                            border: 'none',
                            whiteSpace: 'pre-wrap',
                            wordWrap: 'break-word',
                            padding: '0',
                        }}
                        suppressContentEditableWarning={true}>{sourceCode}</code>
                </pre>
            </div>
            <div className='flex gap-10 mt-2'>
                {!editable && <Button className='' onClick={compileContractHandler}>Deploy</Button>}
                {!editable && <Button className='' onClick={() => setEditable(true)}>Edit</Button>}
                {editable && <Button className='' onClick={() => setEditable(false)}>Save</Button>}
                {!editable && <Button className='' onClick={auditCodeHandler}>Audit</Button>}
            </div>
        </>)
    function compileContractHandler() {
        setDisplayState("compile")
    }
    async function auditCodeHandler() {
        const fetchStreamedData = async () => {
            const response = await fetch("/api/audit-sourceCode",
                {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/json",
                    },
                    body: JSON.stringify({ sourceCode }),
                }
            ); // Fetch data from the server
            setSourceCode("");
            const reader = response.body?.getReader();
            const decoder = new TextDecoder();

            if (reader) {
                let done = false;

                while (!done) {
                    const { value, done: isDone } = await reader.read(); // Read chunks
                    done = isDone;

                    if (value) {
                        // Decode the chunk and append it to the state
                        setSourceCode((prev) => prev + decoder.decode(value));
                    }
                }
            }
        };
        fetchStreamedData();
    }
}