require 'redmine'
require 'digest/md5'
require 'yaml'


class GoogleSpreadsheetMacros
  def self.googless_macro(googless_wiki_content, args, nohead=false)
    key = ""
    query = ""

    if nohead != "true"
      nohead = "false";
    end

    # get a random string to add to the element IDs so multiple spreadsheets don't conflict.
    dom_id = Digest::MD5.hexdigest(rand().to_s)

    raise  "The correct usage is {{ googless(key,query) }}" unless args.length >= 1
    
    #currently not sanitizing the key, to allow for specifying sheets, eg "pCQbetd-CptGXxxQIG7VFIQ&sheet=USA"
    #redmine seemingly html-escapes all the wiki arguments, so we un-escape them
    key = CGI.unescapeHTML(args[0])

    if args.length >= 1
      # Queries can have commas in them, which the macro thinks are extra macro arguments.
      # We know they're just commas in the query, so join them.
      query = CGI.unescape(args[1..-1].join(",").to_s.sub('"', '\"'))
    end
    out = <<"EOF"
  <div>
  <style type="text/css">
  /* this is used to override the th and td className */
  /* see cssClassNames property in the invokation of table.draw() */
    .small-font {
      font-size:80%;
    }
  </style>
  <script type="text/javascript" src="https://www.google.com/jsapi"></script> 
  <script type="text/javascript"> 
  (function () {
    var prot, isFirstTime, options, data, queryInput, querytable_id,
        table_id, display_query_id, fakeSql, nohead, key, lock;

    prot = (("https:" == document.location.protocol) ? "https://" : "http://");
    isFirstTime = true;
    options = {'showRowNumber': true};
    data;
    queryInput;
    querytable_id = 'querytable-' + "#{dom_id}";
    table_id = 'table-' + "#{dom_id}";
    display_query_id = 'display-query-' + "#{dom_id}";
    fakeSql = "#{query}";
    nohead = #{nohead};
    key = '#{key}';
    
    function sendAndDraw() {
      // Send the query with a callback function.
      google.load('visualization', '1', {packages: ['table'], 'callback': function () {
        var query = new google.visualization.Query(prot + 'spreadsheets.google.com/tq?key='+key);
        if(fakeSql) {
          query.setQuery(fakeSql);
        }
        query.send(handleQueryResponse);
      }});
    }
    
    function handleQueryResponse(response) {
      var errorMessage, fullErrorMessage, rawTable, table;
      if (response.isError()) {
        errorMessage = response.nb[0].detailed_message;
        fullErrorMessage = '<div class="flash error"><strong>' +
                           'Google Spreadsheet Error: ' +
                           errorMessage +
                           '</strong></div>';

        $('table-#{dom_id}').replace(fullErrorMessage);
        return;
      }
      data = response.getDataTable();
      rawTable = $(table_id);
      table = new google.visualization.Table(rawTable);  
      table.draw(data, {
        'showRowNumber': true,
        cssClassNames: {
          tableCell: 'small-font',
          headerCell: 'small-font'
        }
      });
      rawTable.setStyle({
        'overflow-x': 'hidden',
        'overflow-y': 'hidden',
        'display': 'inline-block'
      });
    }
    
    lock = false;
    setTimeout(function () {
      if (lock === false) {
        sendAndDraw();
      }
    }, 1000);
    document.observe('dom:loaded', function () {
      lock = true;
      sendAndDraw();
    });
  }());
  </script> 

  </div>
  <div id='table-#{dom_id}'>
  Loading Google Spreadsheet...
  </div>
EOF
  end
  
  # a function for {{googleissue()}}
  def self.get_issue(obj, args)
    # usage: {{googleissue(adfSDFiuhDSF98SDFhiushdafbhIDFXF0dsf)}}
    # gives the row of the google spreadsheet containing the issue number in the second column
    goodargs = []
    goodargs << args[0]
    if not obj.respond_to? :journalized_id or not obj.respond_to? :journalized_type
      if obj.is_a? Issue
        # we're in the "Description" part of the Issue page
        id = obj.id
      end
    else
      # we're in the comment thread of an Issue page
      id = obj.journalized_id
    end
    if id
      col = "B" #assuming second column
      issue_id = id
      issue_id_with_hash = "##{issue_id}"
      goodargs << "SELECT * WHERE #{col}='#{issue_id}' OR #{col}=#{issue_id} OR #{col}='#{issue_id_with_hash}'"
      out = googless_macro(obj, goodargs, "true")
    else
      raise "You need to be on an issue page to use the <strong>googleissue</strong> macro."
    end
  end
end

class GoogleDocumentMacros
  def self.get_doc(obj, args)
    doc_key = args[0]
    if /^\w+$/.match(doc_key)
      url = "https://docs.google.com/a/evolvingweb.ca/document/pub?id=#{doc_key}"
      out = "<iframe src='#{url}'></iframe>"
    else
      raise "The Google document key must be alphanumeric."
    end
  end
end

