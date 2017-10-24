
String grailsHomeRoot = System.properties.getProperty('auditlog.grails.home.root') ?: '/eclipse-common/grails'
String grailsHomePrefix = System.properties.getProperty('auditlog.grails.home.prefix') ?: '/grails-'
String projectDirCommon = "target"
String dotGrailsCommon = "${System.properties.getProperty('user.home')}/.grails"

v22 {
	grailsVersion = '2.2.4'
	pluginVersion = version
	dotGrails = dotGrailsCommon
	projectDir = projectDirCommon
	grailsHome = grailsHomeRoot + grailsHomePrefix + grailsVersion
}

v23 {
	grailsVersion = '2.3.11'
	pluginVersion = version
	dotGrails = dotGrailsCommon
	projectDir = projectDirCommon
	grailsHome = grailsHomeRoot + grailsHomePrefix + grailsVersion
}

v24 {
	grailsVersion = '2.4.4'
	pluginVersion = version
	dotGrails = dotGrailsCommon
	projectDir = projectDirCommon
	grailsHome = grailsHomeRoot + grailsHomePrefix + grailsVersion
}

v25 {
	grailsVersion = '2.5.1'
	pluginVersion = version
	dotGrails = dotGrailsCommon
	projectDir = projectDirCommon
	grailsHome = grailsHomeRoot + grailsHomePrefix + grailsVersion
}

