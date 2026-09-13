module ApplicationHelper
  def sidebar_items
    [
      {
        selected: controller_name == "home",
        label: "Home",
        icon: "bi-house",
        path: root_path
      },
      {
        selected: controller_name == "bank",
        label: "Bank",
        icon: "bi-bank",
        path: ""
      },
      {
        selected: controller_name == "stock_market",
        label: "Stock Market",
        icon: "bi-cash-coin",
        path: ""
      }
    ]
  end
end
