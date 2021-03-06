<%@ page import="java.util.Date" %>
<%@ page import="org.jahia.settings.SettingsBean" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="utility" uri="http://www.jahia.org/tags/utilityLib" %>
<%@ taglib prefix="template" uri="http://www.jahia.org/tags/templateLib" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>
<%@ taglib prefix="user" uri="http://www.jahia.org/tags/user" %>
<%--@elvariable id="currentNode" type="org.jahia.services.content.JCRNodeWrapper"--%>
<%--@elvariable id="out" type="java.io.PrintWriter"--%>
<%--@elvariable id="script" type="org.jahia.services.render.scripting.Script"--%>
<%--@elvariable id="scriptInfo" type="java.lang.String"--%>
<%--@elvariable id="workspace" type="java.lang.String"--%>
<%--@elvariable id="renderContext" type="org.jahia.services.render.RenderContext"--%>
<%--@elvariable id="currentResource" type="org.jahia.services.render.Resource"--%>
<%--@elvariable id="url" type="org.jahia.services.render.URLGenerator"--%>
<%--@elvariable id="module" type="org.jahia.modules.modulemanager.forge.Module"--%>
<c:set var="developmentMode" value="<%= SettingsBean.getInstance().isDevelopmentMode() %>"/>
<template:addResources type="javascript" resources="jquery.min.js,jquery.blockUI.js,workInProgress.js,jquery.cuteTime.js"/>
<template:addResources type="javascript" resources="jquery.cuteTime.settings.${currentResource.locale}.js"/>
<template:addResources type="javascript" resources="datatables/jquery.dataTables.js,i18n/jquery.dataTables-${currentResource.locale}.js,datatables/dataTables.bootstrap-ext.js,settings/dataTables.initializer.js"/>
<template:addResources type="css" resources="datatables/css/bootstrap-theme.css,tablecloth.css"/>
<template:addResources type="css" resources="manageModules.css"/>
<fmt:message key="label.workInProgressTitle" var="i18nWaiting"/><c:set var="i18nWaiting" value="${functions:escapeJavaScript(i18nWaiting)}"/>
<fmt:message key="serverSettings.manageModules.details" var="i18nModuleDetails" />
<fmt:message key="serverSettings.manageModules.checkForUpdates" var="i18nRefreshModules" />
<fmt:message var="lastUpdateTooltip" key="serverSettings.manageModules.lastUpdate">
    <fmt:param value="${lastModulesUpdate}"/>
</fmt:message>

<div class="page-header">
    <h2><fmt:message key="serverSettings.manageModules"/></h2>
</div>

<c:forEach items="${flowRequestContext.messageContext.allMessages}" var="message">
    <c:if test="${message.severity eq 'INFO' || message.severity eq 'ERROR'}">
        <div class="alert alert-${message.severity eq 'INFO' ? 'success' : 'danger'}">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            ${message.text}
        </div>
    </c:if>
</c:forEach>

<c:set var="moduleTableId" value="module_table_${forgeModuleTableUUID}"/>

<template:addResources>
    <script type="text/javascript">
        $(document).ready(function () {
            var tableId = "${moduleTableId}";

            function save_dt_view (oSettings, oData) {
                localStorage.setItem( 'DataTables_adminModulesForgeView', JSON.stringify({id:tableId, data:oData}));
            }
            function load_dt_view (oSettings) {
                var item = localStorage.getItem('DataTables_adminModulesForgeView');
                if(item){
                    var itemJSON = JSON.parse(item);
                    if(itemJSON.data && itemJSON.id == tableId){
                        return itemJSON.data;
                    }
                }
                return undefined;
            }
            
            var customOptions = {"fnStateSave": function(oSettings, oData) { save_dt_view(oSettings, oData); },
            		"fnStateLoad": function(oSettings) { return load_dt_view(oSettings); }};
            
            dataTablesSettings.init(tableId, 10, [[ 5, "asc" ],[ 1, "asc" ]], true, null, customOptions);

            var refreshModulesButton = $("<button class='btn'><i class='icon-refresh'/>&nbsp; ${i18nRefreshModules}</button>");
            refreshModulesButton.on('click', function(){
                $("#reloadModulesForm").submit();
            });

            $('.timestamp').cuteTime({ refresh: 60000 });
            $('.refresh_modules').append(refreshModulesButton).css("float", "right").css("margin-left","10px");
        });
    </script>
</template:addResources>

<form id="viewInstalledModulesForm" style="display: none" action="${flowExecutionUrl}" method="POST">
    <input type="hidden" name="_eventId" value="viewInstalledModules"/>
</form>
<form id="reloadModulesForm" style="display: none" action="${flowExecutionUrl}" method="POST" onsubmit="workInProgress('${i18nWaiting}');">
    <input type="hidden" name="_eventId" value="reloadModules"/>
</form>
<ul class="nav nav-pills">
    <li><a href="#" onclick="$('#viewInstalledModulesForm').submit()"><fmt:message key="serverSettings.manageModules.installedModules"/></a></li>
    <li class="active">
        <a href="#"><fmt:message key="serverSettings.manageModules.availableModules"/></a>
    </li>
    <li class="last-modules-update">
        <span><fmt:message key="serverSettings.manageModules.lastUpdate"/>:&nbsp;<span class="timestamp"><fmt:formatDate value="${lastModulesUpdate}" pattern="yyyy/MM/dd HH:mm"/></span></span>
    </li>
</ul>

<div class="tab-content">

    <div class="panel panel-default">
        <div class="panel-body">
            <div id="moduleDetailsModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="moduleDetailsModalLabel" style="width:960px; margin-left:40px;">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                        <h3 id="moduleDetailsModalLabel"><fmt:message key="serverSettings.manageModules.details"/></h3>
                    </div>
                    <div class="modal-body" style="padding:0; height:480px; max-height:480px">
                        <iframe id="modalframe" frameborder="0" style="width:100%; height:99%"></iframe>
                    </div>
                    </div>
            </div>
            <div class="checkbox">
                <label for="globalModuleAutoStart">
                    <input type="checkbox" name="globalModuleAutoStart" id="globalModuleAutoStart" ${developmentMode ? 'checked="checked"' : ''}/>
                    <fmt:message key="serverSettings.manageModules.download.autoStart"/>&nbsp;
                </label>
            </div>
            <table class="table table-bordered table-striped table-hover" id="${moduleTableId}">
                <thead>
                <tr>
                    <th><fmt:message key='serverSettings.manageModules.moduleName'/></th>
                    <th><fmt:message key='serverSettings.manageModules.moduleId'/></th>
                    <th><fmt:message key='serverSettings.manageModules.groupId'/></th>
                    <th>
                        <fmt:message key="serverSettings.manageModules.version"/>
                    </th>
                    <th>
                        <fmt:message key="serverSettings.manageModules.details"/>
                    </th>
                    <th>
                        <fmt:message key="serverSettings.manageModules.download"/>
                    </th>
                </tr>
                </thead>
        
                <tbody>
                <c:forEach items="${requestScope.modules}" var="module">
                    <tr>
                        <td ><c:if test="${not empty module.icon}"><img style="width:32px; height:32px;padding-right:5px;"  src="${module.icon}"/></c:if>${module.name}</td>
                        <td> ${module.id}</td>
                        <td> ${module.groupId}</td>
                        <td> ${module.version}</td>
                        <c:url value="${module.remoteUrl}" context="/" var="remoteUrl"/>
                        <td>
                            <a data-toggle="modal" role="button" class="btn btn-fab btn-fab-xs btn-info" type="button" data-target="#moduleDetailsModal" onclick="$('#modalframe').attr('src', '${remoteUrl}')">
                                <i class="material-icons">info_outline</i>
                            </a>
                        <td>
        
                        <c:choose>
                            <c:when test="${!module.installable}">
                                <fmt:message key="serverSettings.manageModules.module.canNotInstall" />
                            </c:when>
                            <c:otherwise>
                                <c:remove var="alreadyInstalled" />
                                <c:if test="${not empty allModuleVersions[module.id]}">
                                    <c:forEach items="${allModuleVersions[module.id]}" var="entry">
                                        <c:if test="${entry.key eq module.version}">
                                            <c:set var="alreadyInstalled" value="true" />
                                        </c:if>
                                    </c:forEach>
                                </c:if>
                                
                                <c:choose>
                                    <c:when test="${not empty alreadyInstalled}">
                                        <fmt:message key="serverSettings.manageModules.module.alreadyInstalled" />
                                    </c:when>
                                    <c:otherwise>
                                        <fmt:message key="serverSettings.manageModules.download" var="downloadLabel"/>
                                        <form style="margin: 0;" action="${flowExecutionUrl}" method="POST" onsubmit="this.elements.namedItem('moduleAutoStart').value=document.getElementById('globalModuleAutoStart').checked; workInProgress('${i18nWaiting}');">
                                            <input type="hidden" name="forgeId" value="${module.forgeId}"/>
                                            <input type="hidden" name="moduleUrl" value="${module.downloadUrl}"/>
                                            <input type="hidden" name="moduleAutoStart" value="${developmentMode}"/>
                                            <button data-toggle="tooltip" data-placement="bottom" title="${downloadLabel}" data-original-title="" class="btn btn-fab btn-fab-xs button-download" type="submit" name="_eventId_installForgeModule">
                                                <i class="material-icons">file_download</i>
                                            </button>
                                        </form>
                                    </c:otherwise>
                                </c:choose>
                            </c:otherwise>
                        </c:choose>
        
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</div>