package com.example

import io.pyroscope.http.Format
import io.pyroscope.javaagent.EventType
import io.pyroscope.javaagent.PyroscopeAgent
import io.pyroscope.javaagent.config.Config

import java.time.Instant


class Export {
    static void main(String[] args) {

        pyroscopeLoad()
        def timestamp = Instant.now().toEpochMilli()
        print "export,status=pending,host=${System.getProperty("host")} import_dir=\"${System.getProperty("import_dir")}\" ${timestamp}\n"
    }

    static void pyroscopeLoad() {

        String osName = System.getProperty("os.name")

        if (osName.toLowerCase().contains("windows")) {
            return
        }

        PyroscopeAgent.start(new Config.Builder()
                .setApplicationName("Export")
                .setProfilingEvent(EventType.ITIMER)
                .setFormat(Format.JFR)
                .setServerAddress("http://pyroscope-server:4040")
        // Optionally, if authentication is enabled, specify the API key.
        // .setAuthToken(System.getenv("PYROSCOPE_AUTH_TOKEN"))
                .build())
    }
}
