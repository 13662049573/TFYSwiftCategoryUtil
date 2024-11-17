////
////  PerformanceExportManager.swift
////  TFYSwiftCategoryUtil
////
////  Created by 田风有 on 2024/11/17.
////
//
//import Foundation
//import UIKit
//
//// MARK: - 性能数据导出管理器
//final class PerformanceExportManager {
//    
//    // MARK: - 导出格式
//    enum ExportFormat {
//        case json
//        case csv
//        case pdf
//        case html
//    }
//    
//    // MARK: - 导出方法
//    func exportData(_ profiles: [PerformanceProfile], format: ExportFormat) -> Data? {
//        switch format {
//        case .json:
//            return exportToJSON(profiles)
//        case .csv:
//            return exportToCSV(profiles)
//        case .pdf:
//            return exportToPDF(profiles)
//        case .html:
//            return exportToHTML(profiles)
//        }
//    }
//    
//    // MARK: - JSON导出
//    private func exportToJSON(_ profiles: [PerformanceProfile]) -> Data? {
//        let encoder = JSONEncoder()
//        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
//        encoder.dateEncodingStrategy = .iso8601
//        
//        return try? encoder.encode(profiles)
//    }
//    
//    // MARK: - CSV导出
//    private func exportToCSV(_ profiles: [PerformanceProfile]) -> Data? {
//        var csvString = "Timestamp,Name,CPU Usage,Memory Usage,FPS,Network Throughput\n"
//        
//        for profile in profiles {
//            let row = [
//                formatDate(profile.startTime),
//                profile.name,
//                String(format: "%.2f", profile.metrics.cpuUsage),
//                String(profile.metrics.memoryUsage),
//                String(format: "%.2f", profile.metrics.fps),
//                String(format: "%.2f", profile.metrics.networkThroughput)
//            ].joined(separator: ",")
//            
//            csvString.append(row + "\n")
//        }
//        
//        return csvString.data(using: .utf8)
//    }
//    
//    // MARK: - PDF导出
//    private func exportToPDF(_ profiles: [PerformanceProfile]) -> Data? {
//        let pageWidth: CGFloat = 612  // 8.5 x 11 inches
//        let pageHeight: CGFloat = 792
//        let margin: CGFloat = 50
//        
//        let pdfData = NSMutableData()
//        UIGraphicsBeginPDFContextToData(pdfData, CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), nil)
//        
//        // 添加标题页
//        UIGraphicsBeginPDFPage()
//        let titleAttributes = [
//            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24),
//            NSAttributedString.Key.foregroundColor: UIColor.black
//        ]
//        
//        let title = "Performance Report"
//        let titleSize = title.size(withAttributes: titleAttributes)
//        let titlePoint = CGPoint(
//            x: (pageWidth - titleSize.width) / 2,
//            y: margin
//        )
//        title.draw(at: titlePoint, withAttributes: titleAttributes)
//        
//        // 添加数据页
//        for profile in profiles {
//            UIGraphicsBeginPDFPage()
//            drawProfilePage(profile, pageWidth: pageWidth, margin: margin)
//        }
//        
//        UIGraphicsEndPDFContext()
//        return pdfData as Data
//    }
//    
//    // MARK: - HTML导出
//    private func exportToHTML(_ profiles: [PerformanceProfile]) -> Data? {
//        var html = """
//        <!DOCTYPE html>
//        <html>
//        <head>
//            <meta charset="UTF-8">
//            <title>Performance Report</title>
//            <style>
//                body { font-family: -apple-system, sans-serif; margin: 20px; }
//                .profile { border: 1px solid #ccc; margin: 10px 0; padding: 15px; border-radius: 8px; }
//                .chart { width: 100%; height: 200px; margin: 10px 0; }
//                .metrics { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 10px; }
//                .metric { background: #f5f5f5; padding: 10px; border-radius: 4px; }
//                .critical { color: #ff3b30; }
//                .warning { color: #ffcc00; }
//                .normal { color: #34c759; }
//            </style>
//            <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
//        </head>
//        <body>
//            <h1>Performance Report</h1>
//        """
//        
//        for profile in profiles {
//            html += generateProfileHTML(profile)
//        }
//        
//        html += """
//            <script>
//                // 添加图表初始化代码
//                document.addEventListener('DOMContentLoaded', function() {
//                    // 初始化所有图表
//                    const charts = document.querySelectorAll('.chart');
//                    charts.forEach(function(chart) {
//                        const data = JSON.parse(chart.dataset.values);
//                        const layout = {
//                            margin: { t: 20, r: 20, b: 30, l: 40 },
//                            showlegend: false,
//                            yaxis: { title: chart.dataset.metric }
//                        };
//                        Plotly.newPlot(chart, [{
//                            y: data,
//                            type: 'scatter',
//                            mode: 'lines',
//                            line: { color: '#007aff' }
//                        }], layout);
//                    });
//                });
//            </script>
//        </body>
//        </html>
//        """
//        
//        return html.data(using: .utf8)
//    }
//    
//    // MARK: - 辅助方法
//    private func formatDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        return formatter.string(from: date)
//    }
//    
//    private func drawProfilePage(_ profile: PerformanceProfile, pageWidth: CGFloat, margin: CGFloat) {
//        let textAttributes = [
//            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12),
//            NSAttributedString.Key.foregroundColor: UIColor.black
//        ]
//        
//        var yPosition: CGFloat = margin
//        
//        // 绘制标题
//        let titleAttributes = [
//            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16),
//            NSAttributedString.Key.foregroundColor: UIColor.black
//        ]
//        
//        profile.name.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: titleAttributes)
//        yPosition += 30
//        
//        // 绘制指标
//        let metrics = [
//            "CPU Usage: \(MetricsFormatter.formatCPU(profile.metrics.cpuUsage))",
//            "Memory Usage: \(MetricsFormatter.formatMemory(profile.metrics.memoryUsage))",
//            "FPS: \(MetricsFormatter.formatFPS(profile.metrics.fps))",
//            "Network: \(MetricsFormatter.formatNetwork(profile.metrics.networkThroughput))"
//        ]
//        
//        for metric in metrics {
//            metric.draw(at: CGPoint(x: margin, y: yPosition), withAttributes: textAttributes)
//            yPosition += 20
//        }
//    }
//    
//    private func generateProfileHTML(_ profile: PerformanceProfile) -> String {
//        return """
//        <div class="profile">
//            <h2>\(profile.name)</h2>
//            <p>Duration: \(MetricsFormatter.formatDuration(profile.duration))</p>
//            <div class="metrics">
//                <div class="metric \(getMetricClass(profile.metrics.cpuUsage, threshold: PerformanceThresholds.cpuWarning))">
//                    <h3>CPU Usage</h3>
//                    <p>\(MetricsFormatter.formatCPU(profile.metrics.cpuUsage))</p>
//                </div>
//                <div class="metric \(getMetricClass(Double(profile.metrics.memoryUsage), threshold: Double(PerformanceThresholds.memoryWarning)))">
//                    <h3>Memory Usage</h3>
//                    <p>\(MetricsFormatter.formatMemory(profile.metrics.memoryUsage))</p>
//                </div>
//                <div class="metric \(getMetricClass(profile.metrics.fps, threshold: PerformanceThresholds.fpsWarning, inverted: true))">
//                    <h3>FPS</h3>
//                    <p>\(MetricsFormatter.formatFPS(profile.metrics.fps))</p>
//                </div>
//                <div class="metric \(getMetricClass(profile.metrics.networkThroughput, threshold: PerformanceThresholds.networkWarning))">
//                    <h3>Network</h3>
//                    <p>\(MetricsFormatter.formatNetwork(profile.metrics.networkThroughput))</p>
//                </div>
//            </div>
//            <div id="chart-\(profile.id)" class="chart" data-values="[\(profile.timeSeriesData.joined(separator: ","))]" data-metric="Value"></div>
//        </div>
//        """
//    }
//    
//    private func getMetricClass(_ value: Double, threshold: Double, inverted: Bool = false) -> String {
//        if inverted {
//            if value <= threshold * 0.7 { return "critical" }
//            if value <= threshold { return "warning" }
//        } else {
//            if value >= threshold * 1.3 { return "critical" }
//            if value >= threshold { return "warning" }
//        }
//        return "normal"
//    }
//}
