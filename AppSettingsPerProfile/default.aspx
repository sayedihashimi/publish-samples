<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="default.aspx.cs" Inherits="AppSettingsPerProfile._default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>App settings</title>
    <link href="site.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <h1>App settings</h1>
            <ul>
            <% foreach(var setting in ConfigurationManager.AppSettings.AllKeys) {%>
                <li class="name"><%: setting %></li>
                <li class="value"><%: ConfigurationManager.AppSettings[setting]  %></li>
            <% } %>
            </ul>
        </div>
    </form>
</body>
</html>
