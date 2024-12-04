import Web3BlocksComponentWrapper from "@/components/canvas/whiteboard";
// import { AgentsTable } from "../components/agents/AgentsTable";
// import { Header } from "../components/dashboard/Header";
// import { Stats } from "../components/dashboard/Stats";

export default function Home() {
  {
    return (
      <div className="flex min-h-screen bg-gradient-to-br from-gray-900 via-gray-800 to-gray-900 w-full ">

        <main className="flex-1 w-full">
          {/* <Header />
          <Stats />

          <div className="bg-white/5 backdrop-blur-lg rounded-xl p-6">
            <AgentsTable />
          </div> */}
          <Web3BlocksComponentWrapper/>
        </main>
      </div>
    );
  }
}