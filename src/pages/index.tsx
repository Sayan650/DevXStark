import { AgentsTable } from "../components/agents/AgentsTable";
import { Header } from "../components/dashboard/Header";
import { Stats } from "../components/dashboard/Stats";
import { Sidebar } from "../components/layout/Sidebar";


export default function Home() {
  {
    return (
      <div className="flex min-h-screen bg-gradient-to-br from-gray-900 via-gray-800 to-gray-900">
        <Sidebar />

        <main className="flex-1 p-8">
          <Header />
          <Stats />

          <div className="bg-white/5 backdrop-blur-lg rounded-xl p-6">
            <AgentsTable />
          </div>
        </main>
      </div>
    );
  }
}