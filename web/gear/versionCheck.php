<?php
    // [SGD] Version Checker - PHP v1.2.0 (c) Alex Pascal @ SL.
    // ----------------------------------------------------------------
    define("COLLAR_BETA", "1.2.0");
    define("COLLAR_STABLE", "1.2.0");

    class VersionReport {
        public $collarVersion;
    }

    $reported = new VersionReport();
    $channel = strtolower($_GET["channel"]);

    if ($channel == "beta") {
        $reported->collarVersion = COLLAR_BETA;
    } elseif ($channel == "stable") {
        $reported->collarVersion = COLLAR_STABLE;
    } else {
        exit("Unknown Channel");
    }

    echo json_encode($reported);
?>