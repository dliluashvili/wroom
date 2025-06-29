module.exports = {
	content: ['./src/**/*.{html,js,svelte,ts}'],
	theme: {
		extend: {
			fontFamily: {
				raleway: ['Raleway', 'sans-serif']
			}
		}
	},
	plugins: [require('daisyui')]
}
