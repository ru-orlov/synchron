<?php

declare(strict_types=1);

/**
 * SPDX-FileCopyrightText: 2024 ru-orlov/synchron contributors
 * SPDX-License-Identifier: AGPL-3.0-or-later
 *
 * Manual Update Instructions for Synchron (ru-orlov/synchron fork).
 *
 * This fork operates in offline/manual-update mode. Automatic update checks
 * and downloads from external servers are disabled. Use this page for guidance
 * on how to apply updates manually.
 */

// No authentication required for viewing instructions, but restrict to web context.
if (php_sapi_name() === 'cli') {
	echo "Open this page in a web browser for manual update instructions.\n";
	exit(0);
}

?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Manual Update Instructions – Synchron</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      max-width: 860px;
      margin: 40px auto;
      padding: 0 20px;
      background: #f5f5f5;
      color: #333;
    }
    h1 { color: #0082c9; }
    h2 { color: #555; border-bottom: 1px solid #ccc; padding-bottom: 6px; }
    code, pre {
      background: #e8e8e8;
      padding: 2px 6px;
      border-radius: 3px;
      font-size: 0.95em;
    }
    pre {
      padding: 12px;
      overflow-x: auto;
    }
    .note {
      background: #fff3cd;
      border-left: 4px solid #ffc107;
      padding: 10px 14px;
      margin: 16px 0;
      border-radius: 3px;
    }
    .warning {
      background: #f8d7da;
      border-left: 4px solid #dc3545;
      padding: 10px 14px;
      margin: 16px 0;
      border-radius: 3px;
    }
    ol li { margin-bottom: 10px; }
    a { color: #0082c9; }
  </style>
</head>
<body>

<h1>Synchron – Manual Update Instructions</h1>

<div class="note">
  <strong>Note:</strong> This fork (<a href="https://github.com/ru-orlov/synchron" target="_blank" rel="noreferrer noopener">ru-orlov/synchron</a>)
  operates in <strong>manual-update mode only</strong>. Automatic update checks and downloads
  from external update servers are disabled. Follow the steps below to apply updates manually.
</div>

<h2>Before You Begin</h2>
<ul>
  <li>Check the <a href="https://github.com/ru-orlov/synchron/releases" target="_blank" rel="noreferrer noopener">Synchron Releases page</a> for the latest release and release notes.</li>
  <li>Read the release notes and any critical change notices before upgrading.</li>
  <li>You cannot skip more than one major version at a time (e.g. 27→28 is fine, 27→29 is not).</li>
</ul>

<h2>Step-by-Step Manual Upgrade</h2>

<div class="warning">
  <strong>Always back up before upgrading!</strong> Back up your database, data directory, and
  <code>config/config.php</code> before proceeding.
</div>

<ol>
  <li>
    <strong>Back up</strong> your existing database, <code>data/</code> directory, and
    <code>config/config.php</code>.
  </li>

  <li>
    <strong>Download</strong> the release archive from
    <a href="https://github.com/ru-orlov/synchron/releases" target="_blank" rel="noreferrer noopener">
      https://github.com/ru-orlov/synchron/releases
    </a>
    into an empty directory outside your current installation.
  </li>

  <li>
    <strong>Unpack</strong> the downloaded archive:
    <pre>unzip synchron-[version].zip
# or
tar -xjf synchron-[version].tar.bz2</pre>
  </li>

  <li>
    <strong>Stop your web server</strong> to prevent access during the upgrade.
  </li>

  <li>
    <strong>Disable the cron job</strong> (if configured):
    <pre>crontab -u www-data -e
# Put a # at the start of the Synchron cron line.</pre>
  </li>

  <li>
    <strong>Rename</strong> your current installation directory, e.g. rename
    <code>synchron</code> to <code>synchron-old</code>.
  </li>

  <li>
    <strong>Move</strong> the unpacked new installation into the original location
    (e.g. <code>/var/www/synchron</code>).
  </li>

  <li>
    <strong>Copy</strong> your existing <code>config/config.php</code> into the new installation's
    <code>config/</code> directory.
  </li>

  <li>
    If you keep your <code>data/</code> directory inside the installation folder,
    <strong>move it</strong> from <code>synchron-old/data/</code> to the new installation's
    <code>data/</code> folder. If it is outside the installation, no action is needed.
  </li>

  <li>
    <strong>Copy any custom/third-party apps</strong> from your old <code>apps/</code> folder
    to the new one if they are not already present.
  </li>

  <li>
    <strong>Adjust permissions:</strong>
    <pre>chown -R www-data:www-data synchron
find synchron/ -type d -exec chmod 750 {} \;
find synchron/ -type f -exec chmod 640 {} \;</pre>
  </li>

  <li>
    <strong>Restart your web server.</strong>
  </li>

  <li>
    <strong>Run the upgrade</strong> via the command line:
    <pre>sudo -u www-data php occ upgrade</pre>
  </li>

  <li>
    <strong>Re-enable the cron job</strong> (remove the <code>#</code> you added in step 5).
  </li>
</ol>

<h2>Troubleshooting</h2>

<p>If files do not appear after the upgrade, run a file rescan:</p>
<pre>sudo -u www-data php occ files:scan --all</pre>

<p>If the upgrade gets stuck, disable maintenance mode and retry:</p>
<pre>sudo -u www-data php occ maintenance:mode --off
sudo -u www-data php occ upgrade</pre>

<p>If problems persist, run the repair command:</p>
<pre>sudo -u www-data php occ maintenance:repair</pre>

<p>
  For further assistance, visit the project repository:
  <a href="https://github.com/ru-orlov/synchron" target="_blank" rel="noreferrer noopener">
    https://github.com/ru-orlov/synchron
  </a>
</p>

<p><a href="index.php">← Back to Updater</a></p>

</body>
</html>
