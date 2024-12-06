import React, { useState } from 'react'
import { Button } from '../../../ui/button'
import sample from './sample'
export default function ContractCode({ setDisplayState }) {
    const [editable, setEditable] = useState(false);
    return (
        <>
            <div className='text-black text-2xl font-bold'>Contract Code</div>
            <div
                className={`text-black h-[90%] overflow-y-auto mt-1 custom-scrollbar pl-2 border-4 border-black rounded-e-xl ${editable ? 'bg-yellow-200' : 'bg-yellow-100'}`}>
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
                        suppressContentEditableWarning={true}>{sample}</code>
                </pre>
            </div>
            <div className='flex gap-10 mt-2'>
                {!editable && <Button className='' onClick={compileContractHandler}>Compile</Button>}
                {!editable && <Button className='' onClick={() => setEditable(true)}>Edit</Button>}
                {editable && <Button className='' onClick={() => setEditable(false)}>Save</Button>}
                {!editable && <Button className='' onClick={auditCodeHandler}>Audit</Button>}
            </div>
        </>)
    function compileContractHandler() {
        setDisplayState("compile")
    }
    function auditCodeHandler() {
        setDisplayState("compile")
    }
}