jQuery(function($) {
  $.fn.editable.defaults.mode = 'inline';

  $('.editable-textarea').editable({
    ajaxOptions: {
      type: 'put',
      dataType: 'json'
    },
    rows: 10,
    inputclass: 'textarea-full-width',
    send: "always",
    highlight: "#AD522E",
    success: function(response, newValue) {
        if(!response.success) return response.msg;
    },
    error: function(response, newValue) {
        container = $('.form-well-content')
        error_wrapper = '<div class="alert alert-error"><button class="close" data-dismiss="alert">×</button>'
        error_wrapper_end = '</div>'

        if(response.status === 500) {
            container.prepend(error_wrapper + 'Service unavailable. Please try later.' + error_wrapper_end)
        } else {
            var result = $.parseJSON(response.responseText);
            $.each(result, function(k, v) {
                container.prepend(error_wrapper + "Error with <b>" + k + "</b>: " + v + error_wrapper_end)
            });
        }
    }
  });

  $('.editable').editable({
    ajaxOptions: {
      type: 'put',
      dataType: 'json'
    },
    send: "always",
    highlight: "#AD522E",
    success: function(response, newValue) {
        if(!response.success) return response.msg;
    },
    error: function(response, newValue) {
        container = $('.form-well-content')
        error_wrapper = '<div class="alert alert-error"><button class="close" data-dismiss="alert">×</button>'
        error_wrapper_end = '</div>'

        if(response.status === 500) {
            container.prepend(error_wrapper + 'Service unavailable. Please try later.' + error_wrapper_end)
        } else {
            var result = $.parseJSON(response.responseText);
            $.each(result, function(k, v) {
                container.prepend(error_wrapper + "Error with <b>" + k + "</b>: " + v + error_wrapper_end)
            });
        }
    }
  });
})
