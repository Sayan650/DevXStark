import React, { useState } from 'react'
import { Button } from "@/components/ui/button"
import {
    Credenza,
    CredenzaBody,
    CredenzaContent,
    CredenzaHeader,
    CredenzaTitle,
} from "@/components/credeza"

export default function Compile({ isOpen, onOpenChange, onSubmit, flowSummary }) {
    const [selectedOption, setSelectedOption] = useState("");
    return (
        <div className='bg-black'>
            <Button
                onClick={() => onOpenChange(true)}
                className="bg-[#322131] hover:bg-[#21173E] text-white hoverEffect"
            >
                Compile
            </Button>
            <Credenza open={isOpen} onOpenChange={onOpenChange}>
                <CredenzaContent className="border-white/10">
                    <CredenzaHeader>
                        <CredenzaTitle className="text-white">Confirm</CredenzaTitle>
                        {/* <CredenzaDescription className="text-white/80">
                            Are you sure you want to compile the flow?
                        </CredenzaDescription> */}
                    </CredenzaHeader>
                    <CredenzaBody>
                        <h2 className="text-2xl mt-4 mb-4 text-white">Confirm Flow Summary?</h2>
                        <div className="bg-[#1F1F1F] rounded-lg shadow-md p-4 border-2 border-[#2A2A2A]">
                            {flowSummary.map((item, index) => (
                                <div key={index} className="mb-2 flex items-center">
                                    <span className="mr-2 text-[#FB118E]">{index + 1}.</span>
                                    <span className="text-white">{item.content}</span>
                                </div>
                            ))}
                        </div>

                        <div className="mt-4 flex flex-col gap-1">
                            <div className="text-white text-lg">
                                Select Blockchain:
                            </div>
                            <select
                                id="blockchain-select"
                                value={selectedOption}
                                onChange={(e) => setSelectedOption(e.target.value)}
                                className="ml-2 p-2 bg-gray-800 text-white rounded border border-gray-600"
                                defaultValue=""
                            >
                                <option value="" disabled />
                                <option value="blockchain1">Block Chain1</option>
                                <option value="blockchain2">Block Chain2</option>
                                <option value="blockchain3">Block Chain3</option>
                            </select>

                            {selectedOption && (
                                <p className="text-white mt-2">
                                    You selected: <strong>{selectedOption}</strong>
                                </p>
                            )}
                        </div>
                    </CredenzaBody>
                </CredenzaContent>
            </Credenza>
        </div>
    )
}
