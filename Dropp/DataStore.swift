//
//  DataStore.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 7/16/18.
//  Copyright © 2018 Thumb Taps, LLC. All rights reserved.
//

import Foundation

class DataStore {
	
	class var followedArtists: [Artist] {
		get {
			guard let data = UserDefaults.standard.data(forKey: "followedArtists") else {
				return []
			}
			
			do {
				let artists = try JSONDecoder().decode([Artist].self, from: data)
				return artists.sorted(by: { (artist1, artist2) -> Bool in
					return artist1.name.compare(artist2.name) == .orderedAscending
				})
			} catch {
				print(error)
			}
			
			return []
		}
		set {
			do {
				let data = try JSONEncoder().encode(Array(Set<Artist>(newValue)) /* unique values */)
				UserDefaults.standard.set(data, forKey: "followedArtists")
				UserDefaults.standard.synchronize()
			} catch {
				print(error)
			}
		}
	}
	
	class var releases: [Release] {
		get {
			guard let data = UserDefaults.standard.data(forKey: "releases") else {
				return []
			}
			
			do {
				var releases = try JSONDecoder().decode([Release].self, from: data)
                
                releases = releases.compactMap({ (release) -> Release? in
                    // if the user prefers explicit versions and the release is not explicit
                    if PreferenceStore.preferExplicitVersions && !release.isExplicit {
                        
                        // look for a corresponding explicit release
                        let explicitVersion = releases.first(where: { (potentialMatch) -> Bool in
                            return potentialMatch.isExplicit &&
                                potentialMatch.title == release.title &&
                                potentialMatch.releaseDate == release.releaseDate &&
                                potentialMatch.classification == release.classification
                        })
                        
                        if explicitVersion == nil {
                            return release
                        }
                        
                        return nil
                    }
                    
                    return release.isExplicit && !PreferenceStore.preferExplicitVersions ? nil : release
                })
                
                return releases.filter({ (release) -> Bool in
                    if release.classification == .ep && !PreferenceStore.showEPs {
                        return false
                    }
                    if release.classification == .single && !PreferenceStore.showSingles {
                        return false
                    }
                    return true
                }).sorted(by: { (release1, release2) -> Bool in
					return release1.releaseDate.compare(release2.releaseDate) == .orderedDescending
				})
			} catch {
				print(error)
			}
			
			return []
		}
		set {
			
			do {
				let data = try JSONEncoder().encode(Array(Set<Release>(newValue)) /* unique values */)
				UserDefaults.standard.set(data, forKey: "releases")
				UserDefaults.standard.synchronize()
			} catch {
				print(error)
			}
		}
	}
	
	class func refreshReleases(completion: (() -> Void)?=nil) {
		DispatchQueue.global().async {
			
			var remainingArtists = self.followedArtists.count
			var totalReleases: [Release] = []
			
			guard let date = Calendar.autoupdatingCurrent.date(byAdding: PreferenceStore.releaseHistoryThreshold.unit, value: -(PreferenceStore.releaseHistoryThreshold.amount), to: Date()) else {
				assertionFailure("Unable to determine release history date.")
				return
			}
			
			// get releases for each artist being followed
			self.followedArtists.forEach({ (artist) in
				artist.getReleases(from: date, completion: { (releases, error) in
					guard error == nil else {
						print(error!.localizedDescription)
						return
					}
					
					// add the new releases that aren't already in the new releases array
					totalReleases += releases!
					
					remainingArtists -= 1
					// if there are no more artists
					if (remainingArtists == 0) {
						
						self.releases = totalReleases
						
						completion?()
					}
				})
			})
		}
	}
}


