package profile

import (
	"context"
	"fmt"

	"cloud.google.com/go/firestore"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// Loader loads a user's Profile. The Go service loads it itself for every
// Generation Request rather than trusting the client's copy (H14).
type Loader interface {
	Load(ctx context.Context, uid string) (Profile, error)
}

// FirestoreLoader reads users/{uid}/profile/default with the Admin SDK, which
// bypasses security rules.
type FirestoreLoader struct {
	Client *firestore.Client
}

// Load returns the Normalized Profile. A missing document is the empty
// Profile, which is valid.
func (l FirestoreLoader) Load(ctx context.Context, uid string) (Profile, error) {
	snap, err := l.Client.Collection("users").Doc(uid).Collection("profile").Doc("default").Get(ctx)
	if status.Code(err) == codes.NotFound {
		return Profile{}, nil
	}
	if err != nil {
		return Profile{}, fmt.Errorf("load profile: %w", err)
	}
	return FromDocumentData(snap.Data()).Normalized(), nil
}

// FromDocumentData converts raw Firestore document data into a Profile,
// tolerating anything the rules let through that is not a string: such an
// entry is ignored (docs/firestore-data-model.md, Profile).
func FromDocumentData(data map[string]any) Profile {
	return Profile{
		Listed:            stringList(data["listed"]),
		CustomConstraints: stringMap(data["customConstraints"]),
		Liked:             stringMap(data["liked"]),
		Disliked:          stringMap(data["disliked"]),
		Qualities:         stringMap(data["qualities"]),
	}
}

func stringList(v any) []string {
	items, ok := v.([]any)
	if !ok {
		return nil
	}
	out := make([]string, 0, len(items))
	for _, it := range items {
		if s, ok := it.(string); ok {
			out = append(out, s)
		}
	}
	return out
}

func stringMap(v any) map[string]string {
	m, ok := v.(map[string]any)
	if !ok {
		return nil
	}
	out := make(map[string]string, len(m))
	for k, it := range m {
		if s, ok := it.(string); ok {
			out[k] = s
		}
	}
	return out
}
