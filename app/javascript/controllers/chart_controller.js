import { Controller } from "@hotwired/stimulus"
import * as echarts from "echarts"

// Connects to data-controller="chart"
export default class extends Controller {
  static targets = ["chart", "status"]
  static values = {
    url: String,
    showSymbol: Boolean,
    title: String
  }
  connect() {
    this.chart = echarts.init(this.chartTarget)

    this.resizeObserver = new ResizeObserver(() => {
      this.chart?.resize()
    })
    this.resizeObserver.observe(this.chartTarget)

    this.abortController = new AbortController()

    this.loadData()
  }

  disconnect() {
    this.abortController?.abort()
    this.resizeObserver?.disconnect()

    this.chart?.dispose()
    this.chart = null
  }

  async loadData() {
    this.statusTarget.textContent = "Loading..."

    try {
      const res = await fetch(this.urlValue, {
        headers: { Accept: "application/json" },
        signal: this.abortController.signal
      })

      if (!res.ok) {
        const error = await res.json().catch(() => {})
        throw new Error(error.error || `Request failed: ${res.status}`)
      }

      // Everything went well, let's build the chart
      const points = await res.json()
      console.log(points)

      // Initialize chart with options
      this.chart.setOption({
        title: { text: this.titleValue },
        tooltip: {
          trigger: "axis",
          formatter: (params) => {
            const [isoDate, health] = params[0].value
            const date = new Intl.DateTimeFormat("en-US", {
              month: "long",
              day: "numeric",
              year: "numeric",
              timeZone: "UTC"
            }).format(new Date(isoDate))

            return `${date}<br/>Health: ${health}`
          }
        },
        xAxis: { type: "time" },
        yAxis: { type: "value", min: 0, max: 1000 },
        series: [
          {
            name: "Health",
            type: "line",
            smooth: true,
            data: points,
            showSymbol: this.showSymbolValue || false
          }
        ]
      })

      // Clear out status message
      this.statusTarget.textContent = ""
    } catch (error) {

      console.error("Failed to load economy history:", error)
      this.statusTarget.textContent = error.message
    }
  }
}
