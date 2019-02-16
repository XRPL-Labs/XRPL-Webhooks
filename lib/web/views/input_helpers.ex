defmodule EspyWeb.InputHelper do
  use Phoenix.HTML
  require IEx

  def input(form, field, opts \\ []) do
    type = opts[:using] || Phoenix.HTML.Form.input_type(form, field)
    input = opts[:input] || []

    wrapper_opts = [class: "form-group"]
    label_opts = opts[:label] || [class: "control-label"]
    input_opts = [class: "form-control #{input_state_class(form, field)}"]

    content_tag :div, wrapper_opts do
      label = label(form, field, humanize(field), label_opts)
      input = input(type, form, field, input_opts ++ input)
      error = EspyWeb.ErrorHelpers.error_tag(form, field)
      [label, input, error || ""]
    end
  end

  defp input_state_class(form, field) do
    cond do
      # The form was not yet submitted
      !form.source.action -> ""
      form.errors[field] -> "is-invalid"
      true -> "is-valid"
    end
  end

  # Implement clauses below for custom inputs.
  # defp input(:datepicker, form, field, input_opts) do
  #   raise "not yet implemented"
  # end

  defp input(type, form, field, input_opts) do
    apply(Phoenix.HTML.Form, type, [form, field, input_opts])
  end
end
