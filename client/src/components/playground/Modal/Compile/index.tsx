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
import Loader from './Loader';

type displayComponentProps = "generate" | "contract" | "compile";

export default function Compile({ nodes, edges, isOpen, onOpenChange, flowSummary }) {
    const [displayState, setDisplayState] = useState<displayComponentProps>("generate")
    const [loading, setLoading] = useState(false)
    const [sourceCode, setSourceCode] = useState("");

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
                        {displayState === "generate" && !loading && <GenerateCode setSourceCode={setSourceCode} setLoading={setLoading} nodes={nodes} edges={edges} flowSummary={flowSummary} setDisplayState={setDisplayState} />}

                        {displayState === "generate" && loading && <Loader />}

                        {displayState === "contract" && !loading && <ContractCode setDisplayState={setDisplayState} sourceCode={sourceCode} setLoading={setLoading} setSourceCode={setSourceCode} />}

                        {displayState === "contract" && loading && <Loader />}

                        {displayState === "compile" && <CompileCode setDisplayState={setDisplayState} />}
                        {/* <Loader /> */}
                    </CredenzaBody>
                </CredenzaContent>
            </Credenza>
        </>
    )
}
