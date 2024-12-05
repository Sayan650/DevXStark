import groupedBlocks from "./data";

export default function FloatingSidebar({ addBlock }) {

  return (
    <div className="flex">
      <div className="bg-gray-900 p-4 text-white ">
        <div className="mt-4">
          {Object.entries(groupedBlocks).map(([category, blocks]) => (
            <div key={category} className="mb-2">
              <h4 className="text-sm text-gray-400 my-4">{category}</h4>
              <div className="flex gap-4 flex-wrap">
                {blocks.map((block, index) => (
                  <button
                    key={index}
                    onClick={() => addBlock(block)}
                    className={`relative w-8 h-8 rounded flex items-center justify-center transition-colors text-gray-400 ${block.color} ${block.borderColor} ${block.hoverBorderColor} group hoverEffect`}
                  >
                    {<block.icon size="20" />}
                    {/* Tooltip */}
                    <span
                      className="absolute top-10 left-1/2 transform -translate-x-1/3 whitespace-nowrap bg-black text-white text-xs px-2 py-1 rounded opacity-0 transition-opacity duration-300 group-hover:opacity-100 pointer-events-none"
                    >
                      {block.content}
                    </span>
                  </button>
                ))}
              </div>
            </div>
          ))}
        </div>
        {/* <div className="mb-4">
          <h3 className="text-sm text-gray-400 mb-2">Layers</h3>
          <div className="flex gap-2 flex-wrap">
            <button className="w-8 h-8 rounded flex items-center justify-center transition-colors text-gray-400 hover:bg-gray-700">↓</button>
            <button className="w-8 h-8 rounded flex items-center justify-center transition-colors text-gray-400 hover:bg-gray-700">↑</button>
            <button className="w-8 h-8 rounded flex items-center justify-center transition-colors text-gray-400 hover:bg-gray-700">⊤</button>
            <button className="w-8 h-8 rounded flex items-center justify-center transition-colors text-gray-400 hover:bg-gray-700">⊥</button>
          </div>
        </div> */}
      </div>

      <div className="flex-1 bg-gray-800">
        {/* <!-- Canvas content --> */}
      </div>
    </div>
  );
};
