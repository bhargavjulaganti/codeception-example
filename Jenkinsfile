#!groovy

try {
	node {
		stage("checkout") {
			checkout scm
		}
		stage("test") {
			docker.build("codeception").inside {
				sh "./codecept.phar build"
				if(env.ENVIRONMENT) {
					sh "./codecept.phar run ${env.ENVIRONMENT} -vv"
				} else {
					sh "./codecept.phar run -vv"
				}
			}
		}
	}
	if (env.SUCCESS_NOTIFICATION_ENABLED) {
		slackSend channel: "#${env.SLACK_CHANNEL}", color: "good", message: "`${env.JOB_BASE_NAME}` passed (<${BUILD_URL}|open>)", teamDomain: "${env.SLACK_SUBDOMAIN}", token: "${env.SLACK_TOKEN}"
	}
} catch (err) {
	if (isProduction() || env.FAILURE_NOTIFICATION_ENABLED) {
		slackSend channel: "#${env.SLACK_CHANNEL}", color: "bad", message: "`${env.JOB_BASE_NAME}` failed: $err (<${BUILD_URL}|open>)", teamDomain: "${env.SLACK_SUBDOMAIN}", token: "${env.SLACK_TOKEN}"
	}
	if (currentBuild.result == null || currentBuild.result == "UNSTABLE") {
		currentBuild.result = "FAILURE"
	}
	throw err
} finally {
	reportResultsToInfluxDb()
}

def reportResultsToInfluxDb() {
	if (env.REPORT_RESULTS ?: true) {
		node {
			def influxDb
			if (env.INFLUX_DB) {
				influxDb = env.INFLUX_DB
			} else {
				influxDb = isProduction() ? "production" : "staging"
			}
			def result = 0
			if (currentBuild.result == null) {
				// this means: there is no failures
				currentBuild.result = "SUCCESS"
				result = 1
			}
			step([$class       : 'InfluxDbPublisher',
				  customData   : ['result': result],
				  customDataMap: null,
				  customPrefix : null,
				  target       : influxDb])
		}
	}
}

def isProduction() {
	return env.APPIUM_URL && env.APPIUM_URL.contains("testobject.com")
}
