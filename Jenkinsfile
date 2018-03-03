// Repository name use, must end with / or be '' for none
repository= 'area51/'

// image prefix
imagePrefix = 'ubuntu-dev'

// The image version, master branch is latest in docker
version=BRANCH_NAME
if( version == 'master' ) {
  version = 'latest'
}

// The architectures to build, in format recognised by docker
architectures = [ 'amd64', 'arm64v8' ]

// The  ubuntu versions to build
// 16.04 is there as thats our original so keep support
 ubuntuVersions = [ '16.04', "18.04" ]

// The slave label based on architecture
def slaveId = {
  architecture -> switch( architecture ) {
    case 'amd64':
      return 'AMD64'
    case 'arm64v8':
      return 'ARM64'
    default:
      return 'amd64'
  }
}

// The docker image name
// architecture can be '' for multiarch images
def dockerImage = {
  architecture,  ubuntuVersion -> repository + imagePrefix + ':' +
     ubuntuVersion +
    ( architecture=='' ? '' : ( '-' + architecture ) ) +
    ( version=='latest' ? '' : ( '-' + version ) )
}

// The go arch
def goarch = {
  architecture -> switch( architecture ) {
    case 'amd64':
      return 'amd64'
    case 'arm32v6':
    case 'arm32v7':
      return 'arm'
    case 'arm64v8':
      return 'arm64'
    default:
      return architecture
  }
}

properties( [
  buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '7', numToKeepStr: '10')),
  disableConcurrentBuilds(),
  disableResume(),
  pipelineTriggers([
    upstream('/Public/Alpine/master'),
  ])
])

def buildArch = {
  architecture, ubuntuVersion ->
    node( slaveId( architecture ) ) {
      stage( ubuntuVersion ) {
        checkout scm

        sh 'docker pull  ubuntu:' +  ubuntuVersion

        sh 'docker build' +
          ' -t ' + dockerImage( architecture,  ubuntuVersion ) +
          ' --build-arg  ubuntuVersion=' +  ubuntuVersion +
          ' .'

        sh 'docker push ' + dockerImage( architecture,  ubuntuVersion )
      }
    }

}

node( "AMD64" ) {
  ubuntuVersions.each {
    ubuntuVersion ->
      stage( ubuntuVersion ) {
        parallel(
          'amd64': {
            buildArch( 'amd64', ubuntuVersion )
          }
          'arm64v8': {
            buildArch( 'arm64v8', ubuntuVersion )
          }
        )
      }

      stage( "MultiArch" + ' '+ ubuntuVersion ) {
        // The manifest to publish
        multiImage = dockerImage( '',  ubuntuVersion )

        // Create/amend the manifest with our architectures
        manifests = architectures.collect { architecture -> dockerImage( architecture,  ubuntuVersion ) }
        sh 'docker manifest create -a ' + multiImage + ' ' + manifests.join(' ')

        // For each architecture annotate them to be correct
        architectures.each {
          architecture -> sh 'docker manifest annotate' +
            ' --os linux' +
            ' --arch ' + goarch( architecture ) +
            ' ' + multiImage +
            ' ' + dockerImage( architecture,  ubuntuVersion )
        }

        // Publish the manifest
        sh 'docker manifest push -p ' + multiImage
      }
    }
}
