Formtastic::Helpers::FormHelper.builder = FormtasticBootstrap::FormBuilder

## don't show formtastic inline errors
Formtastic::FormBuilder.inline_errors = :none
## also don't show the star next to the label of each required field
Formtastic::FormBuilder.required_string = ""
