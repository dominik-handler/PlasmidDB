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
        if(response.status === 500) {
            return 'Service unavailable. Please try later.';
        } else {
            return response.responseText;
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
        if(response.status === 500) {
            return 'Service unavailable. Please try later.';
        } else {
            return response.responseText;
        }
    }
  });
})
