import React from "react";
import { useStyleState } from "../hooks/useStyleState";
import { StrokeSection } from "./sections/StrokeSection";

export const Sidebar: React.FC = () => {
  const {
    selectedColor,
    setSelectedColor,
  } = useStyleState();

  return (
    <div className="w-64 bg-gray-900 p-4 text-white h-screen">
      <StrokeSection
        selectedColor={selectedColor}
        onColorSelect={setSelectedColor}
      />
      
    </div>
  );
};
