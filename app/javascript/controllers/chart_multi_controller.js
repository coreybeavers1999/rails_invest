import { Controller } from "@hotwired/stimulus"
import * as echarts from "echarts"

// Connects to data-controller="chart"
export default class extends Controller {
  static targets = ["chart", "status"]
  static values = {
    series: Array, // [ { url, title } ]
    showSymbol: Boolean,
    showLegend: {
      type: Boolean,
      default: true
    },
    title: String,
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
      // Concurrently fetch all url data
      const headers = { Accept: "application/json" }
      const signal = this.abortController.signal
      const promises = this.seriesValue.map(item => fetch(item.url, { headers, signal }))
      const responses = await Promise.all(promises)

      // Catch error
      if (responses.some(res => !res.ok))
        throw new Error(error.error || `Request failed`)

      // Extract json from each response and package up with the series titles
      const seriesPoints = await Promise.all(responses.map(r => r.json()))
      const series = this.seriesValue.map((s, index) => {
        // If this series has marker points, format those here
        let markPoints = undefined
        if (seriesPoints[index]?.event_points) {
          markPoints = {
            symbol: "circle",
            symbolSize: 20,
            label: {
              show: true,
              position: "inside",
              color: "#fff"
            },
            data: seriesPoints[index].event_points
          }
        }

        return {
          name: s.name,
          type: s.type || "line",
          smooth: s.smooth !== undefined ? s.smooth : true,
          data: seriesPoints[index]?.history || [],
          showSymbol: s.showSymbol || false,
          markPoint: markPoints,
        }
      })

      // Configurable legend
      let legend = undefined
      if (this.showLegendValue !== false)
        legend = { data: this.seriesValue.map(s => s.name) }

      // Initialize chart with options
      this.chart.setOption({
        title: { text: this.titleValue },
        tooltip: {
          trigger: "axis",
          formatter: (params) => {
            const date = new Intl.DateTimeFormat("en-US", {
              month: "short",
              day: "numeric",
              year: "numeric",
            }).format(new Date(params[0].axisValue))

            const points = params.map(({ marker, seriesName, value }) => {
              const yValue = Array.isArray(value) ? value[1] : value
              return `${marker}${seriesName}: <b>${yValue}</b>`
            })

            return [date, ...points].join("<br/>")
          }
        },
        legend: legend,
        xAxis: { type: "time" },
        yAxis: { type: "value", min: 0, max: 1000 },
        series: series
      })

      // Clear out status message
      this.statusTarget.textContent = ""
    } catch (error) {

      console.error("Failed to load economy history:", error)
      this.statusTarget.textContent = error.message
    }
  }
}
