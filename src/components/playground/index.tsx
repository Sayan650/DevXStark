import { ReactFlowProvider } from 'reactflow'
import Canvas from './canvas'

// Wrap the main component with ReactFlowProvider
export default function BlocksPlayground() {
  return (
    <ReactFlowProvider>
      <Canvas />
    </ReactFlowProvider>
  )
}
