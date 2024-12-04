import React, { useState } from 'react';
import { AnimatePresence } from 'framer-motion';
import { FloatingMenu } from './FloatingMenu';

const primaryItems = ['A', 'B', 'C', 'D', 'E'];
const secondaryItems = ['1', '2', '3', '4', '5'];

export const MenuSystem: React.FC = () => {
  const [selectedItem, setSelectedItem] = useState<string | null>(null);

  const handlePrimaryItemClick = (item: string) => {
    setSelectedItem(selectedItem === item ? null : item);
  };

  const handleSecondaryItemClick = (item: string) => {
    console.log(`Selected: Primary ${selectedItem}, Secondary ${item}`);
  };

  return (
    <>
      <FloatingMenu
        items={primaryItems}
        onItemClick={handlePrimaryItemClick}
        position="left"
      />
      <AnimatePresence>
        {selectedItem && (
          <FloatingMenu
            items={secondaryItems}
            onItemClick={handleSecondaryItemClick}
            position="right"
          />
        )}
      </AnimatePresence>
    </>
  );
};