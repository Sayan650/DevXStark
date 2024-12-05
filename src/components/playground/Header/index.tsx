import React, { useState } from 'react'
import { Button } from "@/components/ui/button"
import router from "next/router"

export default function Header({ showClearButton, showFinishButton, handleClear, nodes, edges, flowSummary }) {
    const [isEditing, setIsEditing] = useState(false); // To track if we are editing
    const [text, setText] = useState("Project Name");
    return (
        <div className="flex justify-between items-center mt-4 mb-4">
            <div className="flex items-center gap-4 ml-8">
                {/* <h2 className="text-2xl text-white mt-1">Project Name</h2> */}
                {isEditing ? (
                    <input
                        type="text"
                        value={text}
                        onChange={(e) => setText(e.target.value)}
                        onBlur={() => setIsEditing(false)}
                        onKeyDown={(e) => e.key === "Enter" && setIsEditing(false)}
                        className="text-2xl text-white bg-transparent outline-none border-b border-white"
                        autoFocus
                    />
                ) : (
                    <h2 className="text-2xl text-white cursor-pointer" onClick={() => setIsEditing(true)}>
                        {text.length > 0 ? text : "Project Name"}
                    </h2>
                )}
            </div>
            <div className="flex gap-2">
                {showClearButton && (
                    <Button
                        onClick={handleClear}
                        className="px-6 bg-[#252525] hover:bg-[#323232] text-white"
                    >
                        Clear
                    </Button>
                )}
                {showFinishButton && (
                    <Button
                        onClick={() => {
                            const encodedNodes = encodeURIComponent(
                                JSON.stringify(nodes)
                            );
                            const encodedEdges = encodeURIComponent(
                                JSON.stringify(edges)
                            );
                            const encodedFlowSummary = encodeURIComponent(
                                JSON.stringify(flowSummary)
                            );
                            router.push(
                                `/compile?nodes=${encodedNodes}&edges=${encodedEdges}&flowSummary=${encodedFlowSummary}`
                            );
                        }}
                        className="bg-[#322131] hover:bg-[#21173E] text-white"
                    >
                        Compile
                    </Button>
                )}
            </div>
        </div>
    )
}
