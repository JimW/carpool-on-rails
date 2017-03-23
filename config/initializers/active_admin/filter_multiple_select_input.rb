# https://github.com/activeadmin/activeadmin/issues/1743
module ActiveAdmin
  module Inputs
    class MultipleSelectInput < Formtastic::Inputs::SelectInput

      def input_name
        "#{super}_ids"
      end

      def extra_input_html_options
        {
          :class => 'chosen',
          :multiple => true
        }
      end
    end

  end
end
