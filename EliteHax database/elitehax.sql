SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

CREATE DATABASE IF NOT EXISTS `elitehax` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `elitehax`;

CREATE TABLE `achievement` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `internet` int(11) NOT NULL,
  `cpu` int(11) NOT NULL,
  `c2c` int(11) NOT NULL,
  `ram` int(11) NOT NULL,
  `hdd` int(11) NOT NULL,
  `fan` int(11) NOT NULL,
  `gpu` int(11) NOT NULL,
  `firewall` int(11) NOT NULL,
  `ips` int(11) NOT NULL,
  `av` int(11) NOT NULL,
  `malware` int(11) NOT NULL,
  `exploit` int(11) NOT NULL,
  `siem` int(11) NOT NULL,
  `anon` int(11) NOT NULL,
  `webs` int(11) NOT NULL,
  `apps` int(11) NOT NULL,
  `dbs` int(11) NOT NULL,
  `scan` int(11) NOT NULL,
  `attack_w` int(11) NOT NULL,
  `missions` int(11) NOT NULL,
  `max_activity` int(11) NOT NULL,
  `loyal` int(11) NOT NULL,
  `videos` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `attack_log` (
  `id` int(11) NOT NULL,
  `attacker_id` int(11) NOT NULL,
  `defense_id` int(11) NOT NULL,
  `type` varchar(6) NOT NULL,
  `result` int(11) NOT NULL,
  `money_stolen` bigint(15) NOT NULL,
  `rep_change` int(11) NOT NULL,
  `anon` tinyint(1) NOT NULL,
  `timestamp` datetime NOT NULL,
  `attack_chance` int(11) NOT NULL,
  `attack_result` int(11) NOT NULL,
  `seen` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `ban_device` (
  `id` int(11) NOT NULL,
  `device_id` varchar(32) NOT NULL,
  `reason` varchar(100) NOT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `ban_log` (
  `id` int(11) NOT NULL,
  `mod_id` int(11) NOT NULL,
  `ban_id` int(11) NOT NULL,
  `ban_username` varchar(30) NOT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `ban_user` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `reason` varchar(100) NOT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `ban_warning` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `reason` varchar(100) NOT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `botnet` (
  `id` int(11) NOT NULL,
  `attacker_id` int(11) NOT NULL,
  `defense_id` int(11) NOT NULL,
  `attacker_malware` int(11) NOT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `bot_attempt` (
  `id` int(11) NOT NULL,
  `attacker_id` int(11) NOT NULL,
  `defense_id` int(11) NOT NULL,
  `type` varchar(6) NOT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crew` (
  `id` int(11) NOT NULL,
  `name` varchar(20) NOT NULL,
  `tag` varchar(5) NOT NULL,
  `description` varchar(100) NOT NULL,
  `slot` int(11) NOT NULL DEFAULT '10',
  `wallet` bigint(15) NOT NULL,
  `wallet_p` int(11) NOT NULL,
  `daily_wallet` int(11) NOT NULL,
  `tournament_best` int(11) NOT NULL,
  `tournament_won` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `crew_chat` (
  `id` int(20) NOT NULL,
  `crew_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `message` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `crew_invitation` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `crew_id` int(11) NOT NULL,
  `inviter_id` int(11) NOT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crew_logs` (
  `id` int(11) NOT NULL,
  `type` varchar(20) NOT NULL,
  `subtype` varchar(20) NOT NULL,
  `crew_id` int(11) NOT NULL,
  `field1` varchar(20) NOT NULL,
  `field2` varchar(20) NOT NULL,
  `field3` varchar(20) NOT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `crew_requests` (
  `crew_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `crew_wars_logs` (
  `id` int(11) NOT NULL,
  `crew` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `type` varchar(15) NOT NULL,
  `target` varchar(15) NOT NULL,
  `target2` int(10) NOT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `datacenter` (
  `id` int(11) NOT NULL,
  `crew_id` int(11) NOT NULL,
  `region` int(11) NOT NULL,
  `relocation` int(11) NOT NULL DEFAULT '1',
  `cpoints` int(11) NOT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `datacenter_attacks` (
  `id` int(11) NOT NULL,
  `attacking_crew` int(11) NOT NULL,
  `datacenter_id` int(11) NOT NULL,
  `fwext` int(11) NOT NULL,
  `ips` int(11) NOT NULL,
  `siem` int(11) NOT NULL,
  `fwint1` int(11) NOT NULL,
  `fwint2` int(11) NOT NULL,
  `mf1` int(11) NOT NULL,
  `mf2` int(11) NOT NULL,
  `completed` int(11) NOT NULL,
  `completed_timestamp` datetime NOT NULL,
  `fwext_detected` int(11) NOT NULL,
  `ips_detected` int(11) NOT NULL,
  `siem_detected` int(11) NOT NULL,
  `fwint1_detected` int(11) NOT NULL,
  `fwint2_detected` int(11) NOT NULL,
  `mf1_detected` int(11) NOT NULL,
  `mf2_detected` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `datacenter_attack_logs` (
  `id` int(11) NOT NULL,
  `attacking_crew` int(11) NOT NULL,
  `datacenter_id` int(11) NOT NULL,
  `attack_type` varchar(10) NOT NULL,
  `result` int(11) NOT NULL,
  `anon` int(11) NOT NULL,
  `attack_status` int(11) NOT NULL,
  `mf_hack` varchar(1) NOT NULL,
  `cc_reward` int(11) NOT NULL,
  `money_reward` bigint(20) NOT NULL,
  `region` int(11) NOT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `datacenter_scan` (
  `id` int(11) NOT NULL,
  `datacenter_id` int(11) NOT NULL,
  `crew_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `difficult` int(11) NOT NULL,
  `region` int(11) NOT NULL,
  `wallet` bigint(20) NOT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `datacenter_upgrades` (
  `id` int(11) NOT NULL,
  `datacenter_id` int(11) NOT NULL,
  `fwext` int(11) NOT NULL DEFAULT '1',
  `ips` int(11) NOT NULL DEFAULT '1',
  `siem` int(11) NOT NULL DEFAULT '1',
  `fwint1` int(11) NOT NULL DEFAULT '1',
  `fwint2` int(11) NOT NULL DEFAULT '1',
  `mf1` int(11) NOT NULL DEFAULT '1',
  `mf2` int(11) NOT NULL DEFAULT '1',
  `scanner` int(11) NOT NULL DEFAULT '1',
  `exploit` int(11) NOT NULL DEFAULT '1',
  `relocate` int(11) NOT NULL DEFAULT '1',
  `anon` int(11) NOT NULL DEFAULT '1',
  `mf_prod` int(11) NOT NULL,
  `mf1_testprod` int(11) NOT NULL,
  `mf2_testprod` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `economy` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `bots` bigint(15) NOT NULL,
  `missions` bigint(15) NOT NULL,
  `hacks` bigint(15) NOT NULL,
  `income` bigint(15) NOT NULL,
  `upgrades` bigint(15) NOT NULL,
  `money_lost` bigint(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `feedback` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `answer1` int(11) NOT NULL,
  `answer2` int(11) NOT NULL,
  `feedback1` varchar(350) NOT NULL,
  `feedback2` varchar(350) NOT NULL,
  `timestamp1` datetime NOT NULL,
  `timestamp2` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `game_statistics` (
  `id` int(11) NOT NULL,
  `timestamp` datetime NOT NULL,
  `active_players` int(11) NOT NULL,
  `total_players` int(11) NOT NULL,
  `global_money` bigint(15) NOT NULL,
  `webs_attack` int(11) NOT NULL,
  `apps_attack` int(11) NOT NULL,
  `dbs_attack` int(11) NOT NULL,
  `money_attack` int(11) NOT NULL,
  `bot_count` int(11) NOT NULL,
  `rat_count` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `global_chat` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `message` varchar(200) COLLATE utf8_unicode_ci NOT NULL,
  `timestamp` datetime NOT NULL,
  `moderator` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `hack_scenario_actions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `host_id` int(11) NOT NULL,
  `keylogger` int(11) NOT NULL,
  `proxy` int(11) NOT NULL,
  `exploitkit` int(11) NOT NULL,
  `dataexfiltration` int(11) NOT NULL,
  `dumpdb` int(11) NOT NULL,
  `alterdata` int(11) NOT NULL,
  `shutdown` int(11) NOT NULL,
  `defacement` int(11) NOT NULL,
  `ransomware` int(11) NOT NULL,
  `last_message` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `hack_scenario_activities` (
  `id` int(11) NOT NULL,
  `activity` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `net_id` int(11) NOT NULL,
  `host_id` int(11) NOT NULL,
  `service_id` int(11) NOT NULL,
  `vuln_id` int(11) NOT NULL,
  `description` varchar(50) NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `completed` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `hack_scenario_firstnames` (
  `firstname` varchar(50) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `hack_scenario_hosts` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `hostname` varchar(20) NOT NULL,
  `type` varchar(10) NOT NULL,
  `pos` int(11) NOT NULL,
  `os` int(11) NOT NULL,
  `discovered` int(11) NOT NULL,
  `port_scanned` int(11) NOT NULL,
  `fingerprinted` int(11) NOT NULL,
  `vuln_scanned` int(11) NOT NULL,
  `hacked` int(11) NOT NULL,
  `down` int(11) NOT NULL,
  `proxy` int(11) NOT NULL,
  `require_escalation` int(11) NOT NULL,
  `escalated` int(11) NOT NULL,
  `user_discovered` int(11) NOT NULL,
  `connection_discovered` int(11) NOT NULL,
  `contains_data` int(11) NOT NULL,
  `contains_db` int(11) NOT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `hack_scenario_lastnames` (
  `lastname` text NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE `hack_scenario_mission` (
  `id` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `description` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `hack_scenario_missions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `host_id` int(11) NOT NULL,
  `mission_type` int(11) NOT NULL,
  `description` varchar(100) NOT NULL,
  `actions` int(11) NOT NULL,
  `rep` int(11) NOT NULL,
  `completed` int(11) NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `hack_scenario_networks` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `type` varchar(10) NOT NULL,
  `name` varchar(30) NOT NULL,
  `host_scan` int(11) NOT NULL,
  `port_scan` int(11) NOT NULL,
  `social_engineering` int(11) NOT NULL,
  `visible` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `hack_scenario_services` (
  `id` int(11) NOT NULL,
  `host_id` int(11) NOT NULL,
  `service_port` varchar(12) NOT NULL,
  `service_name` varchar(20) NOT NULL,
  `discovered` int(11) NOT NULL,
  `fingerprinted` int(11) NOT NULL,
  `login` int(11) NOT NULL,
  `web` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `hack_scenario_service_name` (
  `id` int(11) NOT NULL,
  `port` varchar(12) NOT NULL,
  `name` varchar(20) NOT NULL,
  `dmza` int(11) NOT NULL,
  `inta` int(11) NOT NULL,
  `clienta` int(11) NOT NULL,
  `inta2` int(11) NOT NULL,
  `login` int(11) NOT NULL,
  `web` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `hack_scenario_users` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `host_id` int(11) NOT NULL,
  `firstname` text NOT NULL,
  `lastname` text NOT NULL,
  `role` int(11) NOT NULL,
  `canSocial` int(11) NOT NULL,
  `canBruteforceUser` int(11) NOT NULL,
  `canBruteforcePass` int(11) NOT NULL,
  `social` int(11) NOT NULL,
  `bruteforceUser` int(11) NOT NULL,
  `bruteforcePass` int(11) NOT NULL,
  `visible` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `hack_scenario_vulnerabilities` (
  `id` int(11) NOT NULL,
  `host_id` int(11) NOT NULL,
  `service_id` int(11) NOT NULL,
  `vuln_name` varchar(50) NOT NULL,
  `vuln_severity` varchar(10) NOT NULL,
  `integrity` int(11) NOT NULL,
  `availability` int(11) NOT NULL,
  `discovered` int(11) NOT NULL,
  `exploited` int(11) NOT NULL,
  `bruteforcedUser` int(11) NOT NULL,
  `bruteforcedPass` int(11) NOT NULL,
  `down` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `ip_reputation` (
  `ip` varchar(46) NOT NULL,
  `status` varchar(10) NOT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `items` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `videos` int(11) NOT NULL,
  `small_packs` int(11) NOT NULL,
  `medium_packs` int(11) NOT NULL,
  `large_packs` int(11) NOT NULL,
  `small_money` int(11) NOT NULL,
  `medium_money` int(11) NOT NULL,
  `large_money` int(11) NOT NULL,
  `ip_change` int(11) NOT NULL,
  `small_oc_packs` int(11) NOT NULL,
  `medium_oc_packs` int(11) NOT NULL,
  `large_oc_packs` int(11) NOT NULL,
  `overclock` int(11) NOT NULL,
  `daily_overclock` int(11) NOT NULL,
  `boosters` int(11) NOT NULL,
  `name_change` int(11) NOT NULL,
  `skill_tree_reset` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `items_pay` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `name_change` int(11) NOT NULL,
  `blue_skin` int(11) NOT NULL,
  `red_skin` int(11) NOT NULL,
  `yellow_skin` int(11) NOT NULL,
  `purple_skin` int(11) NOT NULL,
  `orange_skin` int(11) NOT NULL,
  `silver_skin` int(11) NOT NULL,
  `aqua_skin` int(11) NOT NULL,
  `black_pic` int(11) NOT NULL,
  `gray_pic` int(11) NOT NULL,
  `ghost_pic` int(11) NOT NULL,
  `pirate_pic` int(11) NOT NULL,
  `ninja_pic` int(11) NOT NULL,
  `anon_pic` int(11) NOT NULL,
  `cyborg_pic` int(11) NOT NULL,
  `wolf_pic` int(11) NOT NULL,
  `tiger_pic` int(11) NOT NULL,
  `gas_mask_pic` int(11) NOT NULL,
  `supporter1` int(11) NOT NULL,
  `supporter2` int(11) NOT NULL,
  `supporter3` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `login_audit` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `ip` varchar(15) NOT NULL,
  `device_id` varchar(100) NOT NULL,
  `timestamp` datetime NOT NULL,
  `country` varchar(5) NOT NULL,
  `region` varchar(50) NOT NULL,
  `city` varchar(50) NOT NULL,
  `timezone` varchar(50) NOT NULL,
  `user_timezone` int(11) NOT NULL,
  `user_country` varchar(10) NOT NULL,
  `user_lang` varchar(10) NOT NULL,
  `isp` varchar(50) NOT NULL,
  `anon` varchar(5) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `login_failed` (
  `id` int(11) NOT NULL,
  `ip` varchar(30) COLLATE utf8_unicode_ci NOT NULL,
  `username` varchar(30) COLLATE utf8_unicode_ci NOT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `login_token` (
  `uid` varchar(50) NOT NULL,
  `token` varchar(32) NOT NULL,
  `expire` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `missions` (
  `id` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `subtype` int(11) NOT NULL,
  `difficult` int(11) NOT NULL,
  `target_name` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `description` varchar(300) COLLATE utf8_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `missions_available` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `subtype` int(11) NOT NULL,
  `difficult` int(11) NOT NULL,
  `duration` int(11) NOT NULL,
  `reward` bigint(15) NOT NULL,
  `xp` int(11) NOT NULL,
  `running` tinyint(1) NOT NULL,
  `time_start` datetime NOT NULL,
  `time_finish` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `mission_center` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `lvl` int(11) NOT NULL,
  `upgrade_lvl` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `msg_contacts` (
  `id` int(11) NOT NULL,
  `uuid` varchar(32) CHARACTER SET latin1 NOT NULL,
  `contact` varchar(32) CHARACTER SET latin1 NOT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `msg_request` (
  `id` int(11) NOT NULL,
  `src` varchar(32) CHARACTER SET latin1 NOT NULL,
  `dst` varchar(32) CHARACTER SET latin1 NOT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `nonces` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `nonce` varchar(64) NOT NULL,
  `timestamp` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `overclock` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `oc_start` datetime NOT NULL,
  `oc_end` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `password_reset` (
  `id` int(11) NOT NULL,
  `uid` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `username` varchar(20) COLLATE utf8_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `reset_token` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `token_expire` datetime NOT NULL,
  `hmac` varchar(256) COLLATE utf8_unicode_ci NOT NULL,
  `ip_address` varchar(45) COLLATE utf8_unicode_ci NOT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `player_profile` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `skin` varchar(10) NOT NULL,
  `pic` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `player_token` (
  `id` int(11) NOT NULL,
  `token` varchar(32) NOT NULL,
  `hmac` varchar(256) NOT NULL,
  `expire` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `private_chat` (
  `id` int(11) NOT NULL,
  `uuid1` varchar(32) CHARACTER SET latin1 NOT NULL,
  `uuid2` varchar(32) CHARACTER SET latin1 NOT NULL,
  `message` varchar(1500) NOT NULL,
  `timestamp` datetime NOT NULL,
  `seen` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `purchase` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `item` varchar(11) NOT NULL,
  `g_timestamp` varchar(24) NOT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `rat` (
  `id` int(11) NOT NULL,
  `attacker_id` int(11) NOT NULL,
  `defense_id` int(11) NOT NULL,
  `attacker_malware` int(11) NOT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `region_scan` (
  `id` int(11) NOT NULL,
  `crew_id` int(11) NOT NULL,
  `region` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `register_pending` (
  `id` int(11) NOT NULL,
  `uid` varchar(50) NOT NULL,
  `username` varchar(20) NOT NULL,
  `password` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `activation_token` varchar(32) NOT NULL,
  `token_expire` datetime NOT NULL,
  `hmac` varchar(256) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `register_token` (
  `uid` varchar(50) NOT NULL,
  `token` varchar(32) NOT NULL,
  `expire` datetime NOT NULL,
  `email` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `research` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `coolR1` int(11) NOT NULL,
  `missionR1` int(11) NOT NULL,
  `missionR2` int(11) NOT NULL,
  `missionR3` int(11) NOT NULL,
  `upgradeR1` int(11) NOT NULL,
  `upgradeR2` int(11) NOT NULL,
  `botR1` int(11) NOT NULL,
  `scannerR1` int(11) NOT NULL,
  `scannerR2` int(11) NOT NULL,
  `anonR1` int(11) NOT NULL,
  `anonR2` int(11) NOT NULL,
  `exploitR1` int(11) NOT NULL,
  `exploitR2` int(11) NOT NULL,
  `malwareR1` int(11) NOT NULL,
  `malwareR2` int(11) NOT NULL,
  `fwR1` int(11) NOT NULL,
  `fwR2` int(11) NOT NULL,
  `siemR1` int(11) NOT NULL,
  `siemR2` int(11) NOT NULL,
  `ipsR1` int(11) NOT NULL,
  `ipsR2` int(11) NOT NULL,
  `avR1` int(11) NOT NULL,
  `avR2` int(11) NOT NULL,
  `progR1` int(11) NOT NULL,
  `progR2` int(11) NOT NULL,
  `currentR` varchar(10) NOT NULL,
  `currentD` int(11) NOT NULL,
  `currentT` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `research_audit` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `type` varchar(15) NOT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `reset_attempt` (
  `id` int(11) NOT NULL,
  `ip_address` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `username` varchar(30) COLLATE utf8_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8_unicode_ci NOT NULL,
  `timestamp` datetime NOT NULL,
  `valid` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE `rewards` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `event_id` varchar(64) NOT NULL,
  `reward` int(11) NOT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `skill_tree` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `xp` int(11) NOT NULL,
  `lvl` int(11) NOT NULL,
  `new_lvl_collected` int(11) NOT NULL,
  `skill_points` int(11) NOT NULL,
  `st_hourly` int(11) NOT NULL,
  `st_dev1` int(11) NOT NULL,
  `st_analyst` int(11) NOT NULL,
  `st_mission_speed` int(11) NOT NULL,
  `st_safe_pay` int(11) NOT NULL,
  `st_upgrade_speed` int(11) NOT NULL,
  `st_dev2` int(11) NOT NULL,
  `st_pentester` int(11) NOT NULL,
  `st_stealth` int(11) NOT NULL,
  `st_mission_reward` int(11) NOT NULL,
  `st_bank_exp` int(11) NOT NULL,
  `st_upgrade_cost` int(11) NOT NULL,
  `st_pentester2` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `supporter` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `type` varchar(32) NOT NULL,
  `purchase_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `purchase_id` varchar(24) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `target_list` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `name` varchar(20) NOT NULL,
  `ip` int(11) UNSIGNED NOT NULL,
  `description` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `task` (
  `task_id` int(11) NOT NULL,
  `id` int(11) NOT NULL,
  `type` varchar(20) NOT NULL,
  `lvl` int(11) NOT NULL,
  `starttime` datetime NOT NULL,
  `endtime` datetime NOT NULL,
  `duration` int(11) NOT NULL,
  `part1` int(11) NOT NULL,
  `part2` int(11) NOT NULL,
  `part3` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `task_abort` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tournaments` (
  `id` int(11) NOT NULL,
  `type` int(1) NOT NULL,
  `time_start` time NOT NULL,
  `time_end` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tournaments_new` (
  `id` int(11) NOT NULL,
  `type` int(1) NOT NULL,
  `time_start` time NOT NULL,
  `time_end` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tournament_hack` (
  `id` int(11) NOT NULL,
  `username` varchar(32) NOT NULL,
  `crew` int(11) NOT NULL,
  `money_hack` bigint(15) NOT NULL,
  `hack_count` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tournament_hackdefend` (
  `id` int(11) NOT NULL,
  `username` varchar(32) NOT NULL,
  `crew` int(11) NOT NULL,
  `money_hack` bigint(15) NOT NULL,
  `hack_count` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tournament_hackdefend_finish` (
  `rank` bigint(84) DEFAULT NULL,
  `id` int(11) NOT NULL DEFAULT '0',
  `username` varchar(32) NOT NULL,
  `crew` int(11) NOT NULL,
  `money_hack` bigint(15) NOT NULL,
  `hack_count` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tournament_hackdefend_finish_crew` (
  `crew` int(11) NOT NULL,
  `total` decimal(41,0) DEFAULT NULL,
  `name` varchar(20) CHARACTER SET latin1 NOT NULL,
  `tag` varchar(5) CHARACTER SET latin1 NOT NULL,
  `rank` bigint(21) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tournament_hack_finish` (
  `rank` bigint(84) DEFAULT NULL,
  `id` int(11) NOT NULL,
  `username` varchar(32) NOT NULL,
  `crew` int(11) NOT NULL,
  `money_hack` bigint(15) NOT NULL,
  `hack_count` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tournament_hack_finish_crew` (
  `crew` int(11) NOT NULL,
  `total` decimal(41,0) DEFAULT NULL,
  `name` varchar(20) CHARACTER SET latin1 NOT NULL,
  `tag` varchar(5) CHARACTER SET latin1 NOT NULL,
  `rank` bigint(21) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tournament_score_finish` (
  `rank` bigint(84) DEFAULT NULL,
  `id` int(11) NOT NULL DEFAULT '0',
  `username` varchar(30) CHARACTER SET latin1 NOT NULL,
  `score` bigint(12) NOT NULL DEFAULT '0',
  `tag` varchar(5) CHARACTER SET latin1
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tournament_score_finish_crew` (
  `crew` int(11) NOT NULL,
  `diff` decimal(33,0) DEFAULT NULL,
  `name` varchar(20) CHARACTER SET latin1 NOT NULL,
  `tag` varchar(5) CHARACTER SET latin1 NOT NULL,
  `rank` bigint(84) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tournament_score_start` (
  `id` int(11) NOT NULL DEFAULT '0',
  `username` varchar(30) CHARACTER SET latin1 NOT NULL,
  `score` int(11) NOT NULL,
  `crew` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tournament_score_start_crew` (
  `crew` int(11) NOT NULL,
  `tag` varchar(5) CHARACTER SET latin1 NOT NULL,
  `name` varchar(20) CHARACTER SET latin1 NOT NULL,
  `score` decimal(32,0) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `upgrades` (
  `id` int(11) NOT NULL,
  `internet` int(11) NOT NULL DEFAULT '1',
  `internet_task` int(11) NOT NULL DEFAULT '1',
  `siem` int(11) NOT NULL DEFAULT '1',
  `siem_task` int(11) NOT NULL DEFAULT '1',
  `firewall` int(11) NOT NULL DEFAULT '1',
  `firewall_task` int(11) NOT NULL DEFAULT '1',
  `ips` int(11) NOT NULL DEFAULT '1',
  `ips_task` int(11) NOT NULL DEFAULT '1',
  `c2c` int(11) NOT NULL DEFAULT '1',
  `c2c_task` int(11) DEFAULT '1',
  `anon` int(11) NOT NULL DEFAULT '1',
  `anon_task` int(11) NOT NULL DEFAULT '1',
  `webs` int(11) NOT NULL DEFAULT '1',
  `webs_task` int(11) NOT NULL DEFAULT '1',
  `apps` int(11) NOT NULL DEFAULT '1',
  `apps_task` int(11) NOT NULL DEFAULT '1',
  `dbs` int(11) DEFAULT '1',
  `dbs_task` int(11) NOT NULL DEFAULT '1',
  `cpu` int(11) NOT NULL DEFAULT '1',
  `cpu_task` int(11) NOT NULL DEFAULT '1',
  `ram` int(11) NOT NULL DEFAULT '1',
  `ram_task` int(11) NOT NULL DEFAULT '1',
  `hdd` int(11) NOT NULL DEFAULT '1',
  `hdd_task` int(11) NOT NULL DEFAULT '1',
  `gpu` int(11) NOT NULL DEFAULT '1',
  `gpu_task` int(11) NOT NULL DEFAULT '1',
  `fan` int(11) NOT NULL DEFAULT '1',
  `fan_task` int(11) NOT NULL DEFAULT '1',
  `av` int(11) NOT NULL DEFAULT '1',
  `av_task` int(11) NOT NULL DEFAULT '1',
  `malware` int(11) NOT NULL DEFAULT '1',
  `malware_task` int(11) NOT NULL DEFAULT '1',
  `exploit` int(11) NOT NULL DEFAULT '1',
  `exploit_task` int(11) NOT NULL DEFAULT '1',
  `scan` int(11) NOT NULL DEFAULT '1',
  `scan_task` int(11) NOT NULL DEFAULT '1',
  `cryptominer` int(11) NOT NULL DEFAULT '1',
  `cryptominer_task` int(11) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `user` (
  `id` int(11) NOT NULL,
  `uuid` varchar(32) NOT NULL,
  `username` varchar(30) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(100) NOT NULL,
  `money` bigint(15) NOT NULL,
  `cryptocoins` int(11) NOT NULL,
  `new_cryptocoins` int(11) NOT NULL,
  `score` int(11) NOT NULL,
  `reputation` int(11) NOT NULL,
  `missions_rep` int(11) NOT NULL,
  `ip` int(11) UNSIGNED NOT NULL,
  `creation_time` datetime NOT NULL,
  `last_login` datetime NOT NULL,
  `crew` int(11) NOT NULL,
  `crew_role` int(11) NOT NULL,
  `crew_contribution` int(11) NOT NULL,
  `crew_daily_contribution` int(11) NOT NULL,
  `crew_points` int(11) NOT NULL,
  `crew_chat_timestamp` datetime NOT NULL,
  `crew_log_timestamp` datetime NOT NULL,
  `gc_role` int(11) NOT NULL,
  `login_ip` varchar(30) NOT NULL,
  `device_id` varchar(100) NOT NULL,
  `score_weekly` int(11) NOT NULL,
  `rep_weekly` int(11) NOT NULL,
  `score_monthly` int(11) NOT NULL,
  `rep_monthly` int(11) NOT NULL,
  `rep2_weekly` int(11) NOT NULL,
  `rep2_monthly` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `user_stats` (
  `id` int(11) NOT NULL,
  `attack` int(11) NOT NULL DEFAULT '0',
  `attack_w` int(11) NOT NULL DEFAULT '0',
  `attack_l` int(11) NOT NULL DEFAULT '0',
  `best_attack` bigint(15) NOT NULL,
  `defense` int(11) NOT NULL DEFAULT '0',
  `defense_w` int(11) NOT NULL DEFAULT '0',
  `defense_l` int(11) NOT NULL DEFAULT '0',
  `worst_defense` bigint(15) NOT NULL,
  `money_w` bigint(15) NOT NULL DEFAULT '0',
  `money_l` bigint(15) NOT NULL DEFAULT '0',
  `rep_w` int(11) NOT NULL DEFAULT '0',
  `rep_l` int(11) NOT NULL DEFAULT '0',
  `upgrades` int(11) NOT NULL DEFAULT '0',
  `money_spent` bigint(15) NOT NULL DEFAULT '0',
  `tournament_best` int(11) NOT NULL,
  `tournament_won` int(11) NOT NULL,
  `today_activity` int(11) NOT NULL,
  `current_activity` int(11) NOT NULL,
  `max_activity` int(11) NOT NULL,
  `today_reward` int(11) NOT NULL,
  `missions` int(11) NOT NULL,
  `videos` int(11) NOT NULL,
  `hack_missions` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


ALTER TABLE `achievement`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

ALTER TABLE `attack_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `defense_id` (`defense_id`),
  ADD KEY `attacker_id` (`attacker_id`);

ALTER TABLE `ban_device`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `ban_log`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `ban_user`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `ban_warning`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `botnet`
  ADD PRIMARY KEY (`id`),
  ADD KEY `attacker_id` (`attacker_id`),
  ADD KEY `defense_id` (`defense_id`);

ALTER TABLE `bot_attempt`
  ADD PRIMARY KEY (`id`),
  ADD KEY `attacker_id` (`attacker_id`),
  ADD KEY `defense_id` (`defense_id`);

ALTER TABLE `crew`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `crew_chat`
  ADD PRIMARY KEY (`id`),
  ADD KEY `crew_id` (`crew_id`),
  ADD KEY `user_id` (`user_id`);

ALTER TABLE `crew_invitation`
  ADD PRIMARY KEY (`id`),
  ADD KEY `invitation-crew` (`crew_id`),
  ADD KEY `invitation-user` (`user_id`),
  ADD KEY `invitation-userr` (`inviter_id`);

ALTER TABLE `crew_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `crew_id` (`crew_id`);

ALTER TABLE `crew_requests`
  ADD KEY `crew_id` (`crew_id`),
  ADD KEY `user_id` (`user_id`);

ALTER TABLE `crew_wars_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `crew` (`crew`),
  ADD KEY `user_id` (`user_id`);

ALTER TABLE `datacenter`
  ADD PRIMARY KEY (`id`),
  ADD KEY `crew_id` (`crew_id`);

ALTER TABLE `datacenter_attacks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `attacking_crew` (`attacking_crew`),
  ADD KEY `datacenter_id` (`datacenter_id`);

ALTER TABLE `datacenter_attack_logs`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `datacenter_scan`
  ADD PRIMARY KEY (`id`),
  ADD KEY `datacenter_scan_crew` (`crew_id`);

ALTER TABLE `datacenter_upgrades`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `datacenter_id_3` (`datacenter_id`),
  ADD KEY `datacenter_id` (`datacenter_id`),
  ADD KEY `datacenter_id_2` (`datacenter_id`);

ALTER TABLE `economy`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `feedback`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `game_statistics`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `global_chat`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

ALTER TABLE `hack_scenario_actions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `host_id` (`host_id`);

ALTER TABLE `hack_scenario_activities`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `hack_scenario_firstnames`
  ADD UNIQUE KEY `firstname_2` (`firstname`);
ALTER TABLE `hack_scenario_firstnames` ADD FULLTEXT KEY `firstname` (`firstname`);

ALTER TABLE `hack_scenario_hosts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

ALTER TABLE `hack_scenario_lastnames` ADD FULLTEXT KEY `lastname` (`lastname`);

ALTER TABLE `hack_scenario_mission`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `hack_scenario_missions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `host_id` (`host_id`);

ALTER TABLE `hack_scenario_networks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

ALTER TABLE `hack_scenario_services`
  ADD PRIMARY KEY (`id`),
  ADD KEY `services_host_id` (`host_id`);

ALTER TABLE `hack_scenario_service_name`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `hack_scenario_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `host_id` (`host_id`),
  ADD KEY `user_id` (`user_id`);

ALTER TABLE `hack_scenario_vulnerabilities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `vuln_service` (`service_id`),
  ADD KEY `vuln_host` (`host_id`);

ALTER TABLE `ip_reputation`
  ADD PRIMARY KEY (`ip`),
  ADD KEY `ip` (`ip`);

ALTER TABLE `items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

ALTER TABLE `items_pay`
  ADD PRIMARY KEY (`id`),
  ADD KEY `itemspay_user_id` (`user_id`);

ALTER TABLE `login_audit`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `login_failed`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `missions`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `missions_available`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

ALTER TABLE `mission_center`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

ALTER TABLE `msg_contacts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `uuid` (`uuid`),
  ADD KEY `contact` (`contact`);

ALTER TABLE `msg_request`
  ADD PRIMARY KEY (`id`),
  ADD KEY `msg_src` (`src`),
  ADD KEY `msg_dst` (`dst`);

ALTER TABLE `nonces`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `overclock`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

ALTER TABLE `password_reset`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `player_profile`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

ALTER TABLE `player_token`
  ADD KEY `token` (`token`),
  ADD KEY `id` (`id`);

ALTER TABLE `private_chat`
  ADD PRIMARY KEY (`id`),
  ADD KEY `uuid1` (`uuid1`),
  ADD KEY `uuid2` (`uuid2`);

ALTER TABLE `purchase`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `rat`
  ADD PRIMARY KEY (`id`),
  ADD KEY `attacker_id` (`attacker_id`),
  ADD KEY `defense_id` (`defense_id`);

ALTER TABLE `region_scan`
  ADD PRIMARY KEY (`id`),
  ADD KEY `crew_id` (`crew_id`);

ALTER TABLE `register_pending`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `register_token`
  ADD KEY `uid` (`uid`);

ALTER TABLE `research`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

ALTER TABLE `research_audit`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `reset_attempt`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `rewards`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

ALTER TABLE `skill_tree`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

ALTER TABLE `supporter`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

ALTER TABLE `target_list`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

ALTER TABLE `task`
  ADD PRIMARY KEY (`task_id`),
  ADD KEY `id` (`id`);

ALTER TABLE `task_abort`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

ALTER TABLE `tournaments`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `tournaments_new`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `tournament_hack`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `tournament_hackdefend`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `upgrades`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `user`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id` (`id`),
  ADD KEY `crew` (`crew`),
  ADD KEY `crew_2` (`crew`),
  ADD KEY `uuid` (`uuid`);

ALTER TABLE `user_stats`
  ADD UNIQUE KEY `id_2` (`id`),
  ADD KEY `id` (`id`);


ALTER TABLE `achievement`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `attack_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `ban_device`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `ban_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `ban_user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `ban_warning`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `botnet`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `bot_attempt`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `crew`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `crew_chat`
  MODIFY `id` int(20) NOT NULL AUTO_INCREMENT;

ALTER TABLE `crew_invitation`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `crew_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `crew_wars_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `datacenter`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `datacenter_attacks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `datacenter_attack_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `datacenter_scan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `datacenter_upgrades`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `economy`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `feedback`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `game_statistics`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `global_chat`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `hack_scenario_actions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `hack_scenario_activities`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `hack_scenario_hosts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `hack_scenario_mission`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `hack_scenario_missions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `hack_scenario_networks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `hack_scenario_services`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `hack_scenario_service_name`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `hack_scenario_users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `hack_scenario_vulnerabilities`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `items_pay`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `login_audit`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `login_failed`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `missions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `missions_available`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `mission_center`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `msg_contacts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `msg_request`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `nonces`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `overclock`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `password_reset`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `player_profile`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `private_chat`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `purchase`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `rat`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `region_scan`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `register_pending`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `research`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `research_audit`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `reset_attempt`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `rewards`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `skill_tree`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `supporter`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `target_list`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `task`
  MODIFY `task_id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `task_abort`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `tournaments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `tournaments_new`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `tournament_hackdefend`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;


ALTER TABLE `achievement`
  ADD CONSTRAINT `achievement_userid` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `attack_log`
  ADD CONSTRAINT `attackerid` FOREIGN KEY (`attacker_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `defenseid` FOREIGN KEY (`defense_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `botnet`
  ADD CONSTRAINT `bot_attackerid` FOREIGN KEY (`attacker_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `bot_defenseid` FOREIGN KEY (`defense_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `bot_attempt`
  ADD CONSTRAINT `bota_attackerid` FOREIGN KEY (`attacker_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `bota_defenseid` FOREIGN KEY (`defense_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `crew_chat`
  ADD CONSTRAINT `chat_crewid` FOREIGN KEY (`crew_id`) REFERENCES `crew` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `crew_invitation`
  ADD CONSTRAINT `invitation-crew` FOREIGN KEY (`crew_id`) REFERENCES `crew` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `invitation-user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `invitation-userr` FOREIGN KEY (`inviter_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `crew_logs`
  ADD CONSTRAINT `clogs_crew` FOREIGN KEY (`crew_id`) REFERENCES `crew` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `crew_requests`
  ADD CONSTRAINT `request_crew_id` FOREIGN KEY (`crew_id`) REFERENCES `crew` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `request_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `crew_wars_logs`
  ADD CONSTRAINT `cwl_crew` FOREIGN KEY (`crew`) REFERENCES `crew` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `cwl_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `datacenter`
  ADD CONSTRAINT `datacenter_crew` FOREIGN KEY (`crew_id`) REFERENCES `crew` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `datacenter_attacks`
  ADD CONSTRAINT `da_attacking_crew` FOREIGN KEY (`attacking_crew`) REFERENCES `crew` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `da_dcid` FOREIGN KEY (`datacenter_id`) REFERENCES `datacenter` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `datacenter_scan`
  ADD CONSTRAINT `datacenter_scan_crew` FOREIGN KEY (`crew_id`) REFERENCES `crew` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `datacenter_upgrades`
  ADD CONSTRAINT `dcu_dcid` FOREIGN KEY (`datacenter_id`) REFERENCES `datacenter` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `global_chat`
  ADD CONSTRAINT `chat_userid` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `hack_scenario_actions`
  ADD CONSTRAINT `host_actions_host_id` FOREIGN KEY (`host_id`) REFERENCES `hack_scenario_hosts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `host_actions_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `hack_scenario_hosts`
  ADD CONSTRAINT `hosts_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `hack_scenario_missions`
  ADD CONSTRAINT `hsm_host` FOREIGN KEY (`host_id`) REFERENCES `hack_scenario_hosts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `hsm_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `hack_scenario_networks`
  ADD CONSTRAINT `net_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `hack_scenario_services`
  ADD CONSTRAINT `services_host_id` FOREIGN KEY (`host_id`) REFERENCES `hack_scenario_hosts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `hack_scenario_users`
  ADD CONSTRAINT `hack_scenario_users_hosts` FOREIGN KEY (`host_id`) REFERENCES `hack_scenario_hosts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `hack_scenario_users_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `hack_scenario_vulnerabilities`
  ADD CONSTRAINT `vuln_host` FOREIGN KEY (`host_id`) REFERENCES `hack_scenario_hosts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `vuln_service` FOREIGN KEY (`service_id`) REFERENCES `hack_scenario_services` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `items`
  ADD CONSTRAINT `items_userid` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `items_pay`
  ADD CONSTRAINT `itemspay_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `missions_available`
  ADD CONSTRAINT `mission_userid` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `mission_center`
  ADD CONSTRAINT `mc_userid` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `msg_contacts`
  ADD CONSTRAINT `contact_contact` FOREIGN KEY (`contact`) REFERENCES `user` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `contact_uuid` FOREIGN KEY (`uuid`) REFERENCES `user` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `msg_request`
  ADD CONSTRAINT `msg_dst` FOREIGN KEY (`dst`) REFERENCES `user` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `msg_src` FOREIGN KEY (`src`) REFERENCES `user` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `overclock`
  ADD CONSTRAINT `oc_userid` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `player_profile`
  ADD CONSTRAINT `pp_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `player_token`
  ADD CONSTRAINT `token_userid` FOREIGN KEY (`id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `private_chat`
  ADD CONSTRAINT `pchat_uuid1` FOREIGN KEY (`uuid1`) REFERENCES `user` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `pchat_uuid2` FOREIGN KEY (`uuid2`) REFERENCES `user` (`uuid`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `rat`
  ADD CONSTRAINT `rat_attackerid` FOREIGN KEY (`attacker_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `rat_defenseid` FOREIGN KEY (`defense_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `region_scan`
  ADD CONSTRAINT `rs_crew` FOREIGN KEY (`crew_id`) REFERENCES `crew` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `research`
  ADD CONSTRAINT `research_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `rewards`
  ADD CONSTRAINT `rewards_userid` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `skill_tree`
  ADD CONSTRAINT `st_userid` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `supporter`
  ADD CONSTRAINT `supporter_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `target_list`
  ADD CONSTRAINT `target_userid` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `task`
  ADD CONSTRAINT `task_userid` FOREIGN KEY (`id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `task_abort`
  ADD CONSTRAINT `abort_userid` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `upgrades`
  ADD CONSTRAINT `upgrades_userid` FOREIGN KEY (`id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE `user_stats`
  ADD CONSTRAINT `user_stats_ibfk_1` FOREIGN KEY (`id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
