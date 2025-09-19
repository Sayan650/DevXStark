# DevXStark  

## 🚀 Problem Statement  

Getting into the blockchain ecosystem is extremely tough for both **users** and **developers**.  

- The **user experience** and **developer experience** still need significant improvements.  
- Newcomers often feel **overwhelmed** when introduced to the ecosystem, leading them to **quit early** or avoid building altogether.  
- In the **Starknet ecosystem**, developers face unique challenges due to the **absence of no-code platforms**, making it harder to get started.  

## 💡 Our Solution  

**DevXStark** bridges this gap by making it simple for developers (and even non-developers) to start building on **Starknet** (or other chains) with **minimal coding required**.  

- We leverage **AI agents** to generate, assist, and deploy smart contracts.  
- Our platform reduces the complexity of writing and deploying **Cairo smart contracts**.  
- Users with limited technical knowledge can still build and interact with Starknet.  

This means **faster onboarding, lower learning curves, and an inclusive ecosystem**.  

## ⚙️ Challenges We Faced  

During the hackathon, we encountered two major challenges:  

1. **Contract Compilation & Deployment**  
   - Unlike EVM-compatible chains, **Starknet smart contracts** compile differently.  
   - Code is first compiled into **Sierra**, which is then compiled into **CASM (Cairo Assembly)**.  
   - Writing scripts and figuring out this compilation/deployment pipeline was a major hurdle.  

2. **AI Model Limitations**  
   - Due to time constraints, we couldn’t perform proper **model training**.  
   - Current LLMs struggle to consistently produce **error-free Cairo code** ready for deployment.  
   - Future iterations will include **fine-tuned LLMs** to generate more reliable and production-ready code.  

## 🛠️ Tech Stack  

- **Starknet / Cairo** → Smart contract development  
- **AI Agents / LLMs** → Code generation and developer assistance  
- **Sepolia Testnet** → Deployment and testing  

## 🌍 Impact  

By reducing the barriers to entry, DevXStark empowers:  

- **Developers** → To quickly prototype and deploy without deep Cairo expertise.  
- **Users** → To participate in blockchain development with **low-code / no-code tools**.  
- **Ecosystem** → Faster adoption of Starknet, with improved accessibility and inclusivity.  

## 📌 Future Work  

- Fine-tuning **LLMs** for Cairo-specific code generation.  
- Building a more **intuitive no-code interface** for end users.  
- Expanding support to **other blockchains** beyond Starknet.  
