<?php

/**
 * SPDX-FileCopyrightText: 2016-2024 Nextcloud GmbH and Nextcloud contributors
 * SPDX-FileCopyrightText: 2016 ownCloud, Inc.
 * SPDX-License-Identifier: AGPL-3.0-only
 */
namespace OC\Updater;

use OCP\Http\Client\IClientService;
use OCP\IAppConfig;
use OCP\IConfig;
use OCP\IUserManager;
use OCP\ServerVersion;
use OCP\Support\Subscription\IRegistry;
use OCP\Util;
use Psr\Log\LoggerInterface;

class VersionCheck {
	public function __construct(
		private ServerVersion $serverVersion,
		private IClientService $clientService,
		private IConfig $config,
		private IAppConfig $appConfig,
		private IUserManager $userManager,
		private IRegistry $registry,
		private LoggerInterface $logger,
	) {
	}


	/**
	 * Check if a new version is available
	 *
	 * [SYNCHRON/OFFLINE-MODE] Outbound update checks are disabled in this fork.
	 * This instance (ru-orlov/synchron) operates in manual-update mode only.
	 * Updates must be applied manually; see https://github.com/ru-orlov/synchron
	 * for release downloads and instructions.
	 *
	 * @return array|bool
	 */
	public function check() {
		// [SYNCHRON/OFFLINE-MODE] No outbound network requests to update servers.
		// Manual updates only – see https://github.com/ru-orlov/synchron
		$this->logger->info('Update check skipped: this fork operates in manual-update mode. See https://github.com/ru-orlov/synchron for updates.');
		return false;
	}

	/**
	 * @codeCoverageIgnore
	 * @param string $url
	 * @return resource|string
	 * @throws \Exception
	 */
	protected function getUrlContent($url) {
		$client = $this->clientService->newClient();
		$response = $client->get($url, [
			'timeout' => 5,
		]);
		return $response->getBody();
	}

	private function computeCategory(): int {
		$categoryBoundaries = [
			100,
			500,
			1000,
			5000,
			10000,
			100000,
			1000000,
		];

		$nbUsers = $this->userManager->countSeenUsers();
		foreach ($categoryBoundaries as $categoryId => $boundary) {
			if ($nbUsers <= $boundary) {
				return $categoryId;
			}
		}

		return count($categoryBoundaries);
	}
}
