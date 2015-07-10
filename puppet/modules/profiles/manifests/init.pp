class profiles (
	) {
    notify{"wertt":}
}

class profiles::base (
	) {
    include '::ntp'
}
