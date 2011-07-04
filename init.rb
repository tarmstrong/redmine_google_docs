require 'redmine'

require File.dirname(__FILE__) + '/lib/google_spreadsheet_macros.rb'

Redmine::Plugin.register :redmine_googlesss do
  name "Google Spreadsheet Plugin"
  author 'Tavish Armstrong'
  description 'Embed google spreadsheets in your redmine pages.'
  version '0.0.2'

  Redmine::WikiFormatting::Macros.register do
    desc = "Redmine Google Spreadsheet Macro (gs)"
    macro :gs do |obj, args|
      out = GoogleSpreadsheetMacros.googless_macro(obj, args)
    end

    desc = "Redmine Google Spreadsheet Macro (googless)"
    macro :googless do |obj, args|
      out = GoogleSpreadsheetMacros.googless_macro(obj, args)
    end

    desc = "Redmine Google Spreadsheet Macro (googlespreadsheet)"
    macro :googlespreadsheet do |obj, args|
      out = GoogleSpreadsheetMacros.googless_macro(obj, args)
    end

    desc = "Redmine Google Spreadsheet Macro (googlespread)"
    macro :googlespread do |obj, args|
      out = GoogleSpreadsheetMacros.googless_macro(obj, args)
    end

    desc = "Redmine Google Spreadsheet Macro (gi)"
    macro :gi do |obj, args|
      GoogleSpreadsheetMacros.get_issue(obj, args)
    end

    desc = "Redmine Google Spreadsheet Macro (googleissue)"
    macro :googleissue do |obj, args|
      GoogleSpreadsheetMacros.get_issue(obj, args)
    end
  end
end
