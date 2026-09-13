function findOdd(A) {
    // Make sure A is an array
    if (!Array.isArray(A))
        throw new Error("Value provided must be an array")

    // Map each value with its occurrence count
    const cache = {}
    A.forEach((val) => { cache[val] = (cache[val] || 0) + 1 })

    // Filter the dictionary keys to find the first that has an odd amount
    let needle = null
    let keys = Object.keys(cache)

    for (let i = 0; i < keys.length; i++) {
        const currentKey = keys[i]
        // Does this have an odd count?
        // If so, short circuit to cut iteration cost
        if (cache[currentKey] % 2 !== 0) {
            needle = currentKey
            break
        }

        // Else do nothing, continue
    }

    // Safety: In case none of the numbers have an odd occurance, throw error
    if (needle === null)
        throw new Error("No occurances found")

    return needle;
}


console.log(findOdd([7]))
