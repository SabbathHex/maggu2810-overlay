inherit eutils java-pkg-2 java-ant-2 cvs

# short description
DESCRIPTION="Support classes and native functions for java applications"

# link to homepage
HOMEPAGE="https://darknrg.dyndns.org:28514/index.html"

# license(s)
LICENSE="GPL-2"

# slot (0 for none)
SLOT="0"

# platform keywords
KEYWORDS="~amd64 ~ia64 ~x86 ~x86-fbsd"

# restrict downloading from mirror
RESTRICT="mirror"

# use flags
# (doc and source should not be removed)
IUSE="doc source"

# real name of package
# (used for archive filename-creation,
# cvs module during checkout and
# part of emerge workdir)
MY_PN="HFMNUtils"

# subdirectory under ${S} with source files
# (leave empty for auto-detection)
MY_SRC=""

# class path to main class
# (leave empty for auto-detection)
MY_MAIN=""

# additional arguments for JRE
# (for example: -Xmx512M)
MY_JAVA_ARGS=""

# common dependencies
COMMON_DEP="
	=dev-java/jdom-1.0*"

# dependencies needed for runtime
RDEPEND="
	>=virtual/jre-1.6
	${COMMON_DEP}"

# dependencies needed for build time
DEPEND="
	>=virtual/jdk-1.6
	app-arch/zip
	${COMMON_DEP}"

# list of java packages required during build time
# (will be linked unter lib and must be specified as an array
# package also has to mentioned unter COMMON_DEP!
# for example:
# MY_JAVA_PKGS[0]="jdom-1.0 jdom.jar" with COMMON_DEP="=dev-java/jdom-1.0*")
declare -a MY_JAVA_PKGS
MY_JAVA_PKGS[0]="jdom-1.0 jdom.jar"

# Code that should be executed between linking and building
before_compile() {
	if [ -f check.sh ]; then
		chmod 755 check.sh || die "chmod failed"
		./check.sh || die "calling check.sh failed"
	fi
	
	cd resources || die "cd for native lib failed"
	make || die "make for native lib failed"
	cd .. || die "cd for native lib failed"
}

# Code that should be executed between main class detection
# and java launcher creation
before_install() {
	cd resources || die "cd for native lib failed"
	if grep -q "INST_DIR=" Makefile; then
		sed -i "s:INST_DIR=:INST_DIR=${D}:" Makefile
	else
		sed -i "s:/usr/local/lib:${D}:" Makefile
	fi
	make install || die "make install for native lib failed"
	cd .. || die "cd for native lib failed"
}


##############################################
########## END-OF-USER-CONFIGURATION #########
##############################################


S=${WORKDIR}/${MY_PN}

[ ${#MY_PN} -eq 0 ] && MY_PN=${PN}

[ "${PV}" != "9999" ] && \
	SRC_URI="https://darknrg.dyndns.org:28514/files/pkgs/${MY_PN}-${PV}.tar.bz2"

ECVS_SERVER="darknrg.dyndns.org:/var/lib/cvsd/root"
ECVS_USER="oliver"
ECVS_PASS=""
ECVS_AUTH="ext"
ECVS_MODULE="${MY_PN}"
ECVS_BRANCH="HEAD"
ECVS_TOP_DIR="${DISTDIR}/cvs-src/${MY_PN}"

src_unpack() {
	[ "${PV}" == "9999" ] && cvs_src_unpack || unpack ${A}
}

src_compile() {
	if [ ${#MY_JAVA_PKGS[@]} -gt 0 ]; then
		mkdir lib || die
		for ((i = 0; ${i} < ${#MY_JAVA_PKGS[@]}; i++ )); do
			JP=${MY_JAVA_PKGS[${i}]}
			echo "Linking package ${JP} ..."
			java-pkg_jar-from ${JP} lib/${JP##* }
		done
	fi

	before_compile || die

	eant build makejar
	use doc && eant makedoc
}

src_install() {
	if [ ${#MY_SRC} -eq 0 ]; then
		# extract path attribute of src tag of javac tag from build.xml
		# (usually src or .)
		MY_SRC=`grep "<javac[ >]" build.xml -A999 | \
			grep "</javac>" -B 999 | \
			grep "<src[ >]" -A 1 | \
			grep "path=" | \
			sed "s:.*path=\"\([^\"]*\).*:\1:"`
		[ ${#MY_SRC} -eq 0 ] && die "Cannot extract src path from build.xml"
		einfo "Source path is ${S}/${MY_SRC}"
	fi
	
	if [ ${#MY_MAIN} -eq 0 ]; then
		# find a static void main method and convert the file path to a class path
		for file in `find -type f -name "*.java"`; do
			echo "Checking $file for main() method"
			if grep -q "static void main(" $file; then
				file=${file#./}
				file=${file#${MY_SRC}}
				file=${file##/}
				file=${file%\.java}
				if [ ${#MY_MAIN} -gt 0 ]; then
					ewarn "Found additional main class in $file"
				else
					MY_MAIN=`echo $file | sed "s:/:.:g"`
					einfo "Using ${MY_MAIN} as main class"
				fi
			fi
		done
		[ ${#MY_MAIN} -eq 0 ] && die "Cannot find main class under ${S}/${MY_SRC}"
	fi
	
	before_install || die
	
	[ ${#MY_JAVA_ARGS} -gt 0 ] && JAVA_ARGS="--java_args" || JAVA_ARGS=""
	java-pkg_dolauncher ${PN} --main ${MY_MAIN} ${JAVA_ARGS} ${MY_JAVA_ARGS}
	java-pkg_dojar ${S}/dist/${MY_PN}.jar

	if use doc; then
		einfo "Creating documents from ${S}/dist/docs"
		java-pkg_dohtml -r ${S}/dist/docs
	fi
	if use source; then
		einfo "Creating source archive from ${S}/${MY_SRC}"
		java-pkg_dosrc ${S}/${MY_SRC}
	fi
}