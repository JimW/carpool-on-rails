ActiveAdmin.register_page "Dashboard" do

  # menu priority: 1, label: proc{ I18n.t("active_admin.dashboard") }
  menu false

  content title: proc{ I18n.t("active_admin.dashboard") } do
    div class: "blank_slate_container", id: "dashboard_default_message" do
      span class: "blank_slate" do
        span I18n.t("carpool.dashboard.greeting_line1")
        small I18n.t("carpool.dashboard.greeting_line2")
      end
    end

  end # content
end
