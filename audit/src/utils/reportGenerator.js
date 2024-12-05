// src/utils/reportGenerator.js
class ReportGenerator {
    static generateHtmlReport(auditResult) {
        return `
        <!DOCTYPE html>
        <html>
        <head>
            <title>Starknet Contract Audit Report</title>
            <style>
                body { font-family: Arial, sans-serif; max-width: 800px; margin: auto; }
                .vulnerability { 
                    border: 1px solid #ddd; 
                    margin: 10px 0; 
                    padding: 10px; 
                    background-color: ${auditResult.security_score < 50 ? '#ffeeee' : '#eeffee'}; 
                }
            </style>
        </head>
        <body>
            <h1>Starknet Smart Contract Audit</h1>
            <p>Contract Name: ${auditResult.contract_name}</p>
            <p>Audit Date: ${new Date().toISOString()}</p>
            <p>Security Score: ${auditResult.security_score}/100</p>
            
            <h2>Vulnerabilities</h2>
            ${auditResult.vulnerabilities.map(vuln => `
                <div class="vulnerability">
                    <h3>${vuln.category} - ${vuln.severity}</h3>
                    <p>${vuln.description}</p>
                    <pre>${vuln.recommended_fix}</pre>
                </div>
            `).join('')}
            
            <h2>Recommended Fixes</h2>
            <ul>
                ${auditResult.recommended_fixes.map(fix => `<li>${fix}</li>`).join('')}
            </ul>
        </body>
        </html>
        `;
    }

    static saveReport(reportHtml, filename = 'audit_report.html') {
        const fs = require('fs');
        fs.writeFileSync(filename, reportHtml);
        return filename;
    }
}

module.exports = ReportGenerator;