# Data
industry_list = [
  { name: "Technology", event_chance: 7 },
  { name: "Finance", event_chance: 3 },
  { name: "Real-estate", event_chance: 1 },
  { name: "Hospitality", event_chance: 5 }
]
ceo_list = [
  { name: "Megamind", skill: 100, controversial: 10 },
  { name: "Bonehead McGee", skill: 1, controversial: 100 },
  { name: "Mr Alright", skill: 50, controversial: 50 },
  { name: "Obnoxious Genius", skill: 100, controversial: 100 },
  { name: "Syd Goble" },
  { name: "Corey Beavers" },
  { name: "Jada Beavers" },
  { name: "Kai Beavers" }
]
company_list = {
  "Technology": [
    { name: "Calydon", acronym: "CYDN", ceo_name: "Corey Beavers" },
    { name: "Microsoft", acronym: "MSFT", ceo_name: "Bonehead McGee", value: 1_000_000_000_000 },
    { name: "Apple", acronym: "AAPL", ceo_name: "Obnoxious Genius", value: 500_000_000_000 }
  ],
  "Finance": [
    { name: "Bank of Beavers", acronym: "BOB", ceo_name: "Syd Goble" }
  ],
  "Real-estate": [
    { name: "Beaver Real Estate", acronym: "BRE", ceo_name: "Jada Beavers" }
  ],
  "Hospitality": [
    { name: "Beaver Hotels", acronym: "BHV", ceo_name: "Kai Beavers" }
  ]
}

# Generate industries
industry_start_date = Date.current - 3.years - 1.day
industry_list.each do |industry|
  Stocks::Industry
    .create_with(created_at: industry_start_date, event_chance: industry[:event_chance])
    .find_or_create_by!(name: industry[:name])
end

# List of CEOs
ceo_list.each do |ceo|
  Stocks::Ceo
    .create_with(**ceo)
    .find_or_create_by!(name: ceo[:name])
end

# Create each company
company_list.entries.each do |industry, companies|
  industry = Stocks::Industry.find_by!(name: industry)

  companies.each do |company|
    # Find CEO and delete placeholder key
    ceo = Stocks::Ceo.find_by!(name: company[:ceo_name])
    company.delete(:ceo_name)

    Stocks::Company
      .create_with(**company, industry: industry, ceo: ceo)
      .find_or_create_by!(name: company[:name])
  end
end
