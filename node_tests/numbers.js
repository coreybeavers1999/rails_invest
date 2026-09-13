const baseValue = 128_000_000
const formatter = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD'
})

const multiplier = 0.001
const worst = -160
const best = 190

let worstValue = baseValue
let bestValue = baseValue

for (let i = 0; i < 100; i++) {

    worstValue += worstValue * (multiplier * worst)
    bestValue += bestValue * (multiplier * best)

    // Clamp at 0
    worstValue = Math.max(0, worstValue)

    console.log(`Day: ${i+1} - ${formatter.format(worstValue)} | ${formatter.format(bestValue)}`)
}

