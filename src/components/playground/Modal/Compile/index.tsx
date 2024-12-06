import React, { useState } from 'react'
import { Button } from "@/components/ui/button"
import {
    Credenza,
    CredenzaBody,
    CredenzaContent,
    CredenzaHeader,
    CredenzaTitle,
} from "@/components/credeza"
import GenerateCode from './GenerateCode';
import ContractCode from './ContractCode';
import CompileCode from './CompileCode';

type displayComponentProps = "generate" | "contract" | "compile";

export default function Compile({ isOpen, onOpenChange, onSubmit, flowSummary }) {
    const [displayState, setDisplayState] = useState<displayComponentProps>("generate")
    return (
        <>
            <Button
                onClick={() => onOpenChange(true)}
                className="bg-[#322131] hover:bg-[#21173E] text-white hoverEffect"
            >
                Generate
            </Button>
            <Credenza open={isOpen} onOpenChange={onOpenChange}>
                <CredenzaContent className={`border-white/10 bg-[#faf3dd] max-w-[100vh] ${displayState === "generate" && 'w-[60vh]'}`}>
                    <CredenzaBody className='max-h-[84vh] max-w-[95vh]'>
                        {displayState === "generate" && <GenerateCode flowSummary={flowSummary} setDisplayState={setDisplayState} />}
                        {displayState === "contract" && <ContractCode setDisplayState={setDisplayState} />}
                        {displayState === "compile" && <CompileCode setDisplayState={setDisplayState} />}
                    </CredenzaBody>
                </CredenzaContent>
            </Credenza>
        </>
    )
}
