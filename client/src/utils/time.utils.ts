/**
 * Smart time formatter that adapts based on video duration
 *
 * - For videos under 1 minute: Shows seconds only (e.g., "28s")
 * - For videos under 1 hour: Shows minutes:seconds (e.g., "04:28")
 * - For videos 1 hour or longer: Shows hours:minutes:seconds (e.g., "01:04:28")
 *
 * @param seconds Current time in seconds
 * @param totalDuration Total video duration in seconds
 * @returns Formatted time string
 */
export function formatVideoTime(seconds: number, totalDuration: number): string {
	// Round down to get whole seconds
	const wholeSeconds = Math.floor(seconds)

	// For videos under 1 minute
	if (totalDuration < 60) {
		return `${wholeSeconds}s`
	}

	// For videos under 1 hour
	if (totalDuration < 3600) {
		const mins = Math.floor(wholeSeconds / 60)
		const secs = wholeSeconds % 60
		return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
	}

	// For videos 1 hour or longer
	const hrs = Math.floor(wholeSeconds / 3600)
	const mins = Math.floor((wholeSeconds % 3600) / 60)
	const secs = wholeSeconds % 60
	return `${hrs.toString().padStart(2, '0')}:${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`
}

