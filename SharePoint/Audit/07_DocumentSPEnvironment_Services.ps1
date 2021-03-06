############################################################################################################################################
# Script para documentar las configuraciones comunes de un ambiente de SharePoint
# Parámetros necesarios: 
#    -> N/A
# Referencias:
#    -> http://technet.microsoft.com/en-us/library/ff645391(v=office.14).aspx
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

#Hacemos un buen uso de PowerShell para no penalizar el rendimiento
$host.Runspace.ThreadOptions = "ReuseThread"

#Determinamos primero el tipo de producto instalado
function Get-InstalledProduct
{
    $spInstalledProducts=Get-SPProduct
    foreach($spInstalledProduct in $spInstalledProducts) 
    {        
        #Si el producto es SharePoint Foundation           
        if($spInstalledProduct.ProductName -eq "Microsoft SharePoint Foundation 2010")
        {
            return $spInstalledProduct.ProductName
            break
        }
        
        #Si el producto es SharePoint Server        
        if($spInstalledProduct.ProductName -eq "Microsoft SharePoint Server 2010")
        {
            return $spInstalledProduct.ProductName
            break
        }
    } 
}

Start-SPAssignment –Global

#############################################################################################################################################
##Servicios comunes de infraestructura
#############################################################################################################################################

#Aplicaciones de servicio en la granja
Get-SPServiceApplication  | Export-Clixml .\Get-SPServiceApplication.xml
Get-SPServiceApplicationPool  | Export-Clixml .\Get-SPServiceApplicationPool.xml
Get-SPServiceApplicationProxy  | Export-Clixml .\Get-SPServiceApplicationProxy.xml
Get-SPServiceApplicationProxyGroup  | Export-Clixml .\Get-SPServiceApplicationProxyGroup.xml
Get-SPServiceApplication | Get-SPServiceApplicationEndpoint  | Export-Clixml .\Get-SPServiceApplicationEndpoint.xml

#Servicios ejecutándose en la granja
Get-SPServiceInstance  | Export-Clixml .\Get-SPServiceInstance.xml

#Información sobre configuraciones comunes de Servicio Web
Get-SPServiceHostConfig  | Export-Clixml .\Get-SPServiceHostConfig.xml

#Configuraciones especificas de SharePoint Server 2010
$sProduct=Get-InstalledProduct 
if ($sProduct -eq "Microsfot SharePoint Server 2010")
{
    #Información sobre los servicios de formularios InfoPath
    Get-SPInfoPathFormsService  | Export-Clixml .\Get-SPInfoPathFormsService.xml
    Get-SPInfoPathFormTemplate  | Export-Clixml .\Get-SPInfoPathFormTemplate.xml

    ###WARNING: Se requieren permisos de administrador para ejecutar este comando
    Get-SPInfoPathUserAgent  | Export-Clixml .\Get-SPInfoPathUserAgent.xml
    
    Get-SPWebApplication | Get-SPInfoPathWebServiceProxy  | Export-Clixml .\Get-SPInfoPathWebServiceProxy.xml
}

###############################################################################################################################################
## Configuraciones comunes de Aplicaciones de Servicio
###############################################################################################################################################

###############################################################################################################################################
#Aplicaciones de SharePoint Foundation 2010
###############################################################################################################################################

#Application Discovery & Load Balancer Service Application 
Get-SPTopologyServiceApplication  | Export-Clixml .\Get-SPTopologyServiceApplication.xml
Get-SPTopologyServiceApplicationProxy  | Export-Clixml .\Get-SPTopologyServiceApplicationProxy.xml

#Security Token Service Application
Get-SPSecurityTokenServiceConfig  | Export-Clixml .\Get-SPSecurityTokenServiceConfig.xml

#Usage and Health data collection
Get-SPUsageApplication  | Export-Clixml .\Get-SPUsageApplication.xml
Get-SPUsageDefinition  | Export-Clixml .\Get-SPUsageDefinition.xml
Get-SPUsageService  | Export-Clixml .\Get-SPUsageService.xml

#Búsquedas
Get-SPSearchService  | Export-Clixml .\Get-SPSearchService.xml
Get-SPSearchServiceInstance  | Export-Clixml .\Get-SPSearchServiceInstance.xml
    
###############################################################################################################################################
#Aplicaciones de Servicio en SharePoint Server 2010
###############################################################################################################################################

if ($sProduct -eq "Microsfot SharePoint Server 2010")
{
    #Servicios de Access
    #Get-SPAccessServiceApplication  | Export-Clixml .\Get-SPAccessServiceApplication.xml
    
    #Archivos de conexiones de datos -> Se requieren privilegios de administrador
    Get-SPDataConnectionFile | Export-Clixml .\Get-SPDataConnectionFile.xml
    Get-SPDataConnectionFile | Get-SPDataConnectionFileDependent  | Export-Clixml .\Get-SPDataConnectionFileDependent.xml
    
    #Servicios de Excel
    Get-SPExcelServiceApplication | Get-SPExcelBlockedFileType  | Export-Clixml .\Get-SPExcelBlockedFileType.xml
    Get-SPExcelServiceApplication | Get-SPExcelDataConnectionLibrary  | Export-Clixml .\Get-SPExcelDataConnectionLibrary.xml
    Get-SPExcelServiceApplication | Get-SPExcelDataProvider  | Export-Clixml .\Get-SPExcelDataProvider.xml
    Get-SPExcelServiceApplication | Get-SPExcelFileLocation  | Export-Clixml .\Get-SPExcelFileLocation.xml
    Get-SPExcelServiceApplication | Export-Clixml .\Get-SPExcelServiceApplication.xml
    Get-SPExcelServiceApplication | Get-SPExcelUserDefinedFunction  | Export-Clixml .\Get-SPExcelUserDefinedFunction.xml
    
    #Metadatos Administrados
    Get-SPServiceApplication | ?{$_.TypeName -eq "Managed Metadata Service"} | %{$id = $_.Id;Get-SPMetadataServiceApplication -Id $_ | Export-Clixml .\Get-SPMetadataServiceApplication-$id.xml}
    Get-SPServiceApplicationProxy | ?{$_.TypeName -eq "Managed Metadata Service Connection"} | %{$id = $_.Id;Get-SPMetadataServiceApplicationProxy -Id $_ | Export-Clixml .\Get-SPMetadataServiceApplicationProxy-$id.xml}
    Get-SPSite | Get-SPTaxonomySession  | Export-Clixml .\Get-SPTaxonomySession.xml
    
    #PerformancePoint
    Get-SPPerformancePointServiceApplication | Get-SPPerformancePointSecureDataValues  | Export-Clixml .\Get-SPPerformancePointSecureDataValues.xml
    Get-SPPerformancePointServiceApplication | Export-Clixml .\Get-SPPerformancePointServiceApplication.xml
    Get-SPPerformancePointServiceApplication | Get-SPPerformancePointServiceApplicationTrustedLocation  | Export-Clixml .\Get-SPPerformancePointServiceApplicationTrustedLocation.xml

    #Búsquedas
    Get-SPEnterpriseSearchServiceApplication | Get-SPEnterpriseSearchAdministrationComponent  | Export-Clixml .\Get-SPEnterpriseSearchAdministrationComponent.xml
    Get-SPEnterpriseSearchServiceApplication | Get-SPEnterpriseSearchCrawlContentSource  | Export-Clixml .\Get-SPEnterpriseSearchCrawlContentSource.xml
    Get-SPEnterpriseSearchServiceApplication | Get-SPEnterpriseSearchCrawlCustomConnector  | Export-Clixml .\Get-SPEnterpriseSearchCrawlCustomConnector.xml
    Get-SPEnterpriseSearchServiceApplication | Get-SPEnterpriseSearchCrawlDatabase  | Export-Clixml .\Get-SPEnterpriseSearchCrawlDatabase.xml
    Get-SPEnterpriseSearchServiceApplication | Get-SPEnterpriseSearchCrawlExtension  | Export-Clixml .\Get-SPEnterpriseSearchCrawlExtension.xml
    Get-SPEnterpriseSearchServiceApplication | Get-SPEnterpriseSearchCrawlMapping  | Export-Clixml .\Get-SPEnterpriseSearchCrawlMapping.xml
    Get-SPEnterpriseSearchServiceApplication | Get-SPEnterpriseSearchCrawlRule  | Export-Clixml .\Get-SPEnterpriseSearchCrawlRule.xml
    Get-SPEnterpriseSearchServiceApplication | Get-SPEnterpriseSearchCrawlTopology  | Export-Clixml .\Get-SPEnterpriseSearchCrawlTopology.xml
    $searchApp = Get-SPEnterpriseSearchServiceApplication; Get-SPEnterpriseSearchExtendedClickThroughExtractorJobDefinition -SearchApplication $searchApp | Export-Clixml .\Get-SPEnterpriseSearchExtendedClickThroughExtractorJobDefinition.xml
    Get-SPEnterpriseSearchServiceApplication | Get-SPEnterpriseSearchExtendedConnectorProperty  | Export-Clixml .\Get-SPEnterpriseSearchExtendedConnectorProperty.xml
    Get-SPEnterpriseSearchServiceApplication | Get-SPEnterpriseSearchExtendedQueryProperty  | Export-Clixml .\Get-SPEnterpriseSearchExtendedQueryProperty.xml
    ###WARNING: Se genera un archivo de + de 120 MB.
    Get-SPEnterpriseSearchServiceApplication | Get-SPEnterpriseSearchLanguageResourcePhrase  | Export-Clixml .\Get-SPEnterpriseSearchLanguageResourcePhrase.xml
    Get-SPEnterpriseSearchServiceApplication | Get-SPEnterpriseSearchMetadataCategory  | Export-Clixml .\Get-SPEnterpriseSearchMetadataCategory.xml
    Get-SPEnterpriseSearchServiceApplication | Get-SPEnterpriseSearchMetadataCrawledProperty  | Export-Clixml .\Get-SPEnterpriseSearchMetadataCrawledProperty.xml
    Get-SPEnterpriseSearchServiceApplication | Get-SPEnterpriseSearchMetadataManagedProperty  | Export-Clixml .\Get-SPEnterpriseSearchMetadataManagedProperty.xml
    Get-SPEnterpriseSearchServiceApplication | Get-SPEnterpriseSearchMetadataMapping  | Export-Clixml .\Get-SPEnterpriseSearchMetadataMapping.xml
    Get-SPEnterpriseSearchServiceApplication | Get-SPEnterpriseSearchPropertyDatabase  | Export-Clixml .\Get-SPEnterpriseSearchPropertyDatabase.xml
    Get-SPEnterpriseSearchServiceApplication | Get-SPEnterpriseSearchQueryAuthority  | Export-Clixml .\Get-SPEnterpriseSearchQueryAuthority.xml
    Get-SPEnterpriseSearchServiceApplication | Get-SPEnterpriseSearchQueryDemoted  | Export-Clixml .\Get-SPEnterpriseSearchQueryDemoted.xml
    Get-SPEnterpriseSearchQueryAndSiteSettingsService  | Export-Clixml .\Get-SPEnterpriseSearchQueryAndSiteSettingsService.xml
    Get-SPEnterpriseSearchQueryAndSiteSettingsServiceInstance  | Export-Clixml .\Get-SPEnterpriseSearchQueryAndSiteSettingsServiceInstance.xml
    Get-SPEnterpriseSearchQueryAndSiteSettingsServiceProxy  | Export-Clixml .\Get-SPEnterpriseSearchQueryAndSiteSettingsServiceProxy.xml
    Get-SPEnterpriseSearchService  | Export-Clixml .\Get-SPEnterpriseSearchService.xml
    Get-SPEnterpriseSearchServiceInstance  | Export-Clixml .\Get-SPEnterpriseSearchServiceInstance.xml    
    ###WARNING: Configuraciones por Colección de Sitios
    Get-SPSite | %{$id = $_.Id;Get-SPEnterpriseSearchQueryKeyword -Site $_ | Export-Clixml .\Get-SPEnterpriseSearchQueryKeyword-$id.xml}
    Get-SPEnterpriseSearchServiceApplication | Get-SPEnterpriseSearchQueryScope  | Export-Clixml .\Get-SPEnterpriseSearchQueryScope.xml
    Get-SPEnterpriseSearchServiceApplication | Get-SPEnterpriseSearchQueryScope | Get-SPEnterpriseSearchQueryScopeRule  | Export-Clixml .\Get-SPEnterpriseSearchQueryScopeRule.xml
    Get-SPEnterpriseSearchServiceApplication | Get-SPEnterpriseSearchQuerySuggestionCandidates  | Export-Clixml .\Get-SPEnterpriseSearchQuerySuggestionCandidates.xml
    Get-SPEnterpriseSearchServiceApplication | Get-SPEnterpriseSearchQueryTopology  | Export-Clixml .\Get-SPEnterpriseSearchQueryTopology.xml
    Get-SPEnterpriseSearchServiceApplication | Get-SPEnterpriseSearchRankingModel  | Export-Clixml .\Get-SPEnterpriseSearchRankingModel.xml
    Get-SPEnterpriseSearchServiceApplication | Get-SPEnterpriseSearchSecurityTrimmer  | Export-Clixml .\Get-SPEnterpriseSearchSecurityTrimmer.xml
    Get-SPEnterpriseSearchServiceApplication | Export-Clixml .\Get-SPEnterpriseSearchServiceApplication.xml
    Get-SPEnterpriseSearchServiceApplicationProxy  | Export-Clixml .\Get-SPEnterpriseSearchServiceApplicationProxy.xml
    Get-SPEnterpriseSearchSiteHitRule  | Export-Clixml .\Get-SPEnterpriseSearchSiteHitRule.xml
    
    ##State Service Application
    Get-SPSessionStateService  | Export-Clixml .\Get-SPSessionStateService.xml
    Get-SPStateServiceApplication  | Export-Clixml .\Get-SPStateServiceApplication.xml
    Get-SPStateServiceApplicationProxy  | Export-Clixml .\Get-SPStateServiceApplicationProxy.xml
    Get-SPStateServiceDatabase  | Export-Clixml .\Get-SPStateServiceDatabase.xml
    
    #Servicios de Visio    
    Get-SPVisioServiceApplication | Get-SPVisioExternalData  | Export-Clixml .\Get-SPVisioExternalData.xml
    Get-SPVisioServiceApplication | Get-SPVisioPerformance  | Export-Clixml .\Get-SPVisioPerformance.xml
    Get-SPVisioServiceApplication | Get-SPVisioSafeDataProvider  | Export-Clixml .\Get-SPVisioSafeDataProvider.xml
    Get-SPVisioServiceApplication | Export-Clixml .\Get-SPVisioServiceApplication.xml
    Get-SPVisioServiceApplicationProxy  | Export-Clixml .\Get-SPVisioServiceApplicationProxy.xml

    #Web Analytics Service Application
    Get-SPServiceApplication | ?{$_.TypeName -eq "Web Analytics Service Application"} | %{$id = $_.Id;Get-SPWebAnalyticsServiceApplication -Id $_ | Export-Clixml .\Get-SPWebAnalyticsServiceApplication-$id.xml}
    Get-SPServiceApplicationProxy | ?{$_.TypeName -eq "Web Analytics Service Application Proxy"} | %{$id = $_.Id;Get-SPWebAnalyticsServiceApplicationProxy -Id $_ | Export-Clixml .\Get-SPWebAnalyticsServiceApplicationProxy-$id.xml}
    Get-SPWebApplication | Get-SPWebApplicationHttpThrottlingMonitor  | Export-Clixml .\Get-SPWebApplicationHttpThrottlingMonitor.xml
    Get-SPWebPartPack  | Export-Clixml .\Get-SPWebPartPack.xml
}

Stop-SPAssignment –Global

Remove-PsSnapin Microsoft.SharePoint.PowerShell