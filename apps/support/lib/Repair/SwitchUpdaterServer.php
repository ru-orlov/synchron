<?php

declare(strict_types=1);

/**
 * SPDX-FileCopyrightText: 2020 Nextcloud GmbH and Nextcloud contributors
 * SPDX-License-Identifier: AGPL-3.0-or-later
 */

namespace OCA\Support\Repair;

use OCP\IConfig;
use OCP\Migration\IOutput;
use OCP\Migration\IRepairStep;
use OCP\Support\Subscription\IRegistry;

class SwitchUpdaterServer implements IRepairStep {
	public function __construct(
		protected readonly IConfig $config,
		protected readonly IRegistry $subscriptionRegistry,
	) {
	}

	public function getName(): string {
		return 'Switches from default updater server to the customer one if a valid subscription is available';
	}

	public function run(IOutput $output): void {
		// [SYNCHRON/OFFLINE-MODE] External updater-server switching is disabled.
		// This fork (ru-orlov/synchron) operates in manual-update mode only.
		// No outbound calls to updates.nextcloud.com are made.
		// See https://github.com/ru-orlov/synchron for update instructions.
		$output->info('Updater server switching is disabled in offline/manual-update mode.');
	}
}
