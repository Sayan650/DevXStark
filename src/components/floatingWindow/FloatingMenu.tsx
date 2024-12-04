import React, { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

interface FloatingMenuProps {
  items: string[];
  onItemClick: (item: string) => void;
  position?: 'left' | 'right';
}

export const FloatingMenu: React.FC<FloatingMenuProps> = ({ 
  items, 
  onItemClick,
  position = 'left'
}) => {
  return (
    <motion.div
      className={`fixed ${position === 'left' ? 'left-8' : 'right-8'} top-1/2 -translate-y-1/2 bg-white rounded-lg shadow-lg p-2`}
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: 20 }}
    >
      <div className="flex flex-col gap-2">
        {items.map((item) => (
          <motion.button
            key={item}
            onClick={() => onItemClick(item)}
            className="w-12 h-12 rounded-lg bg-gray-100 hover:bg-gray-200 flex items-center justify-center text-gray-700 font-medium transition-colors"
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
          >
            {item}
          </motion.button>
        ))}
      </div>
    </motion.div>
  );
};