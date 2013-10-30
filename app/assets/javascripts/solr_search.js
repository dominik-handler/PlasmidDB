jQuery(function($) {
  $('.search-query').keyup(function(e) {
    text = $('.search-query').val();
    if(text.length > 2) {
      refresh_index(text);
    }
    else if (text.length == 0) {
      refresh_index("*");
    }
  });

  function refresh_index(currVal) {
    $.ajax('/filter_plasmid_index', {
      type: 'GET',
      cache: false,
      data: {filter: currVal},
      dataType: 'json',
      success: function(data) {
        container = $('.table-striped tbody');
        container.empty();
        $.each(data, function(idx) {
          item = data[idx];
          container.append(construct_plasmid_index_item(item));
        });
      },
      error: function(data) {
        alert('blah error')
      }
    });
  }

  function construct_plasmid_index_item(item) {
    html = '<tr><td><b>' + item.internal_id + '</b></td><td><a href="/plasmids/' + item.id + '">' + item.plasmid_name + '</a></td><td>' + item.gene_insert + '</td><td>' + item.author + '</td><td>' + item.time_added + '</td>';
    html += '<td><a href="/plasmids/' + item.id + '" class="btn btn-danger btn-mini" data-confirm="Are you sure?" data-method="delete" rel="nofollow"><i class="icon-trash icon-white"></i></a>\n'
    return html;
  }
})
